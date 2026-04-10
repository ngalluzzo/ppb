@tool
class_name Projectile
extends CharacterBody2D

const ProjectileBehaviorRulesScript = preload("res://weapon/projectile/logic/projectile_behavior_rules.gd")
const ProjectileCollisionRulesScript = preload("res://weapon/projectile/logic/projectile_collision_rules.gd")
const ProjectileImpactFactoryScript = preload("res://weapon/projectile/logic/projectile_impact_factory.gd")
const ProjectileMotionRulesScript = preload("res://weapon/projectile/logic/projectile_motion_rules.gd")
const ProjectilePhysicsAdapterScript = preload("res://weapon/projectile/logic/projectile_physics_adapter.gd")
const ProjectileRuntimeStateScript = preload("res://weapon/projectile/logic/projectile_runtime_state.gd")
const ProjectilePresentationScript = preload("res://weapon/projectile/presentation/projectile_presentation.gd")
const WorldLifecycleAdapterScript = preload("res://shared/runtime/world_lifecycle_adapter.gd")

signal impact_submitted(event: ImpactEvent)

const GIZMO_COLLISION := Color(0.30, 0.70, 0.98, 0.90)
const GIZMO_DETECTION := Color(0.99, 0.84, 0.36, 0.75)
const GIZMO_VELOCITY := Color(0.97, 0.39, 0.39, 0.95)
const GIZMO_TRAIL := Color(0.46, 0.86, 0.42, 0.90)
const GIZMO_OFFSET := Color(0.86, 0.58, 0.99, 0.95)

var _editor_show_gizmos_value: bool = true
var _editor_show_collision_radius_value: bool = true
var _editor_show_detection_radius_value: bool = true
var _editor_show_velocity_arrow_value: bool = true
var _editor_show_trail_value: bool = true
var _editor_show_body_offset_value: bool = true
var _editor_show_labels_value: bool = true
var _editor_trail_point_limit_value: int = 24

@export_group("Editor Preview")
@export var editor_show_gizmos: bool = true:
	get:
		return _editor_show_gizmos_value
	set(value):
		_editor_show_gizmos_value = value
		_on_editor_debug_changed()

@export var editor_show_collision_radius: bool = true:
	get:
		return _editor_show_collision_radius_value
	set(value):
		_editor_show_collision_radius_value = value
		_on_editor_debug_changed()

@export var editor_show_detection_radius: bool = true:
	get:
		return _editor_show_detection_radius_value
	set(value):
		_editor_show_detection_radius_value = value
		_on_editor_debug_changed()

@export var editor_show_velocity_arrow: bool = true:
	get:
		return _editor_show_velocity_arrow_value
	set(value):
		_editor_show_velocity_arrow_value = value
		_on_editor_debug_changed()

@export var editor_show_trail: bool = true:
	get:
		return _editor_show_trail_value
	set(value):
		_editor_show_trail_value = value
		_on_editor_debug_changed()

@export var editor_show_body_offset: bool = true:
	get:
		return _editor_show_body_offset_value
	set(value):
		_editor_show_body_offset_value = value
		_on_editor_debug_changed()

@export var editor_show_labels: bool = true:
	get:
		return _editor_show_labels_value
	set(value):
		_editor_show_labels_value = value
		_on_editor_debug_changed()

@export_range(4, 64, 1) var editor_trail_point_limit: int = 24:
	get:
		return _editor_trail_point_limit_value
	set(value):
		_editor_trail_point_limit_value = maxi(4, value)
		_trim_debug_trail()
		_on_editor_debug_changed()

@onready var detection_area: Area2D = $DetectionArea
@onready var projectile_body: AnimatedSprite2D = $ProjectileBody
@onready var projectile_collision: CollisionShape2D = $ProjectileCollision
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D

var projectile_def: ProjectileDefinition
var shot_event: ShotEvent
var battle_system: BattleSystem
var shot_id: int = 0
var projectile_index: int = 0
var behavior_context: BehaviorContext = BehaviorContext.new()
var _physics_adapter: ProjectilePhysicsAdapter
var _runtime_state: ProjectileRuntimeState
var _lifecycle_adapter: WorldLifecycleAdapter = WorldLifecycleAdapterScript.new()
var _presentation: ProjectilePresentation = ProjectilePresentationScript.new()
var _debug_trail_points: Array[Vector2] = []

func initialize_from_shot(event: ShotEvent, index: int, p_battle_system: BattleSystem) -> void:
	shot_event = event
	battle_system = p_battle_system
	shot_id = event.shot_id
	projectile_index = index
	projectile_def = event.projectile_definition
	velocity = event.base_velocity
	_runtime_state = ProjectileRuntimeStateScript.new(0.0, 0.0, event.muzzle_position, Vector2.ZERO)
	sync_spawn_transform(event.muzzle_position)
	_on_editor_debug_changed()

func sync_spawn_transform(spawn_position: Vector2) -> void:
	global_position = spawn_position
	if _runtime_state != null:
		_runtime_state.prev_position = spawn_position
	_debug_trail_points.clear()
	_record_debug_trail_point()
	_on_editor_debug_changed()

func _ready() -> void:
	_ensure_runtime_state()
	_physics_adapter = ProjectilePhysicsAdapterScript.new(
		Callable(self, "_physics_move_and_slide"),
		Callable(self, "_physics_get_slide_collision_count"),
		Callable(self, "_physics_get_slide_collision"),
		Callable(self, "_physics_get_overlap_areas")
	)
	_presentation.setup_definition(projectile_body, projectile_collision, detection_collision, projectile_def)
	_presentation.start_flight(projectile_body)
	_record_debug_trail_point()
	_on_editor_debug_changed()

func _physics_process(delta: float) -> void:
	if shot_event == null:
		return
	_ensure_runtime_state()
	var motion_step: Dictionary = ProjectileMotionRulesScript.begin_frame(_runtime_state, velocity, shot_event, delta)
	_runtime_state = motion_step["state"]
	velocity = motion_step["velocity"]
	var terrain_contact: SurfaceContact = _physics_adapter.move_body()

	if terrain_contact != null:
		_on_terrain_impact(terrain_contact)
		return

	_check_zone_overlap()
	if not is_inside_tree():
		return

	var frame_result: Dictionary = ProjectileMotionRulesScript.finish_frame(_runtime_state, global_position, shot_event)
	_runtime_state = frame_result["state"]
	_runtime_state.active_body_offset = ProjectileBehaviorRulesScript.compute_body_offset(
		shot_event,
		_runtime_state,
		projectile_index,
		velocity,
		behavior_context,
		frame_result["raw_progress"],
		frame_result["progress"]
	)
	var body_rotation = ProjectileMotionRulesScript.compute_body_rotation(velocity)
	_presentation.apply_runtime_visuals(projectile_body, _runtime_state.active_body_offset, velocity, body_rotation)
	_record_debug_trail_point()
	_on_editor_debug_changed()

func _check_zone_overlap() -> void:
	for overlap_hit in _physics_adapter.get_overlap_hits():
		var mobile: Mobile = overlap_hit.mobile
		if mobile == null:
			continue
		if ProjectileCollisionRulesScript.should_ignore_mobile_overlap(
			mobile,
			shot_event,
			projectile_def,
			_runtime_state.distance_traveled if _runtime_state != null else 0.0
		):
			continue
		var zone: ImpactEvent.HitZone = overlap_hit.zone
		if zone != ImpactEvent.HitZone.NONE:
			_on_mobile_impact(mobile, zone)
			return

func _on_terrain_impact(collision: SurfaceContact) -> void:
	var event: ImpactEvent = ProjectileImpactFactoryScript.build_terrain_impact(
		global_position,
		collision.normal,
		projectile_def,
		shot_id,
		projectile_index,
		shot_event
	)
	_submit_impact(event)

func _on_mobile_impact(mobile: Mobile, zone: ImpactEvent.HitZone) -> void:
	var event: ImpactEvent = ProjectileImpactFactoryScript.build_mobile_impact(
		global_position,
		projectile_def,
		shot_id,
		projectile_index,
		shot_event,
		mobile,
		zone
	)
	_submit_impact(event)

func _submit_impact(event: ImpactEvent) -> void:
	impact_submitted.emit(event)
	if battle_system != null:
		battle_system.resolve_impact(event)
	_lifecycle_adapter.free_node(self)

func _ensure_runtime_state() -> void:
	if _runtime_state == null:
		_runtime_state = ProjectileRuntimeStateScript.new(0.0, 0.0, global_position, Vector2.ZERO)

func _physics_move_and_slide() -> void:
	move_and_slide()

func _physics_get_slide_collision_count() -> int:
	return get_slide_collision_count()

func _physics_get_slide_collision(index: int):
	return get_slide_collision(index)

func _physics_get_overlap_areas() -> Array:
	return detection_area.get_overlapping_areas()

func get_debug_snapshot() -> Dictionary:
	return {
		"shot_id": shot_id,
		"projectile_index": projectile_index,
		"projectile_name": projectile_def.name if projectile_def != null else "",
		"position": global_position,
		"velocity": velocity,
		"speed": velocity.length(),
		"distance_traveled": _runtime_state.distance_traveled if _runtime_state != null else 0.0,
		"spin_time": _runtime_state.spin_time if _runtime_state != null else 0.0,
		"body_offset": _runtime_state.active_body_offset if _runtime_state != null else Vector2.ZERO,
		"collision_radius": _get_collision_radius(),
		"detection_radius": _get_detection_radius(),
		"trail_point_count": _debug_trail_points.size(),
	}

func _draw() -> void:
	if not Engine.is_editor_hint() or not _editor_show_gizmos_value:
		return
	_draw_debug_trail()
	_draw_debug_radii()
	_draw_debug_body_offset()
	_draw_debug_velocity_arrow()
	_draw_debug_labels()

func _draw_debug_trail() -> void:
	if not _editor_show_trail_value or _debug_trail_points.size() < 2:
		return
	for index in range(1, _debug_trail_points.size()):
		draw_line(
			to_local(_debug_trail_points[index - 1]),
			to_local(_debug_trail_points[index]),
			GIZMO_TRAIL,
			2.0
		)

func _draw_debug_radii() -> void:
	if _editor_show_collision_radius_value:
		var collision_radius := _get_collision_radius()
		if collision_radius > 0.0:
			draw_arc(Vector2.ZERO, collision_radius, 0.0, TAU, 48, GIZMO_COLLISION, 2.0)
	if _editor_show_detection_radius_value:
		var detection_radius := _get_detection_radius()
		if detection_radius > 0.0:
			draw_arc(Vector2.ZERO, detection_radius, 0.0, TAU, 48, GIZMO_DETECTION, 2.0)

func _draw_debug_body_offset() -> void:
	if not _editor_show_body_offset_value or _runtime_state == null:
		return
	var offset := _runtime_state.active_body_offset
	if offset == Vector2.ZERO:
		return
	draw_line(Vector2.ZERO, offset, GIZMO_OFFSET, 2.0)
	draw_circle(offset, 4.0, GIZMO_OFFSET)

func _draw_debug_velocity_arrow() -> void:
	if not _editor_show_velocity_arrow_value:
		return
	var speed := velocity.length()
	if speed <= 0.0:
		return
	var direction := velocity.normalized()
	var arrow_length := clampf(speed * 0.08, 24.0, 96.0)
	var arrow_end := direction * arrow_length
	draw_line(Vector2.ZERO, arrow_end, GIZMO_VELOCITY, 3.0)
	var head := direction * 10.0
	var perp := Vector2(-direction.y, direction.x) * 6.0
	draw_line(arrow_end, arrow_end - head + perp, GIZMO_VELOCITY, 3.0)
	draw_line(arrow_end, arrow_end - head - perp, GIZMO_VELOCITY, 3.0)

func _draw_debug_labels() -> void:
	if not _editor_show_labels_value:
		return
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var snapshot := get_debug_snapshot()
	draw_string(
		font,
		Vector2(12.0, -18.0),
		"p%s %s" % [snapshot.projectile_index, snapshot.projectile_name if snapshot.projectile_name != "" else "projectile"],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		GIZMO_COLLISION
	)
	draw_string(
		font,
		Vector2(12.0, -2.0),
		"speed=%.1f dist=%.1f trail=%s" % [snapshot.speed, snapshot.distance_traveled, snapshot.trail_point_count],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		GIZMO_DETECTION
	)

func _record_debug_trail_point() -> void:
	_debug_trail_points.append(global_position)
	_trim_debug_trail()

func _trim_debug_trail() -> void:
	while _debug_trail_points.size() > _editor_trail_point_limit_value:
		_debug_trail_points.remove_at(0)

func _get_collision_radius() -> float:
	if projectile_collision != null and projectile_collision.shape is CircleShape2D:
		return (projectile_collision.shape as CircleShape2D).radius
	if projectile_def != null:
		return projectile_def.collision_radius
	return 0.0

func _get_detection_radius() -> float:
	if detection_collision != null and detection_collision.shape is CircleShape2D:
		return (detection_collision.shape as CircleShape2D).radius
	return _get_collision_radius()

func _on_editor_debug_changed() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
