@tool
class_name Mobile
extends CharacterBody2D

const MobileDamageRulesScript = preload("res://mobile/logic/mobile_damage_rules.gd")
const MobileLocomotionScript = preload("res://mobile/logic/mobile_locomotion.gd")
const FloorContactStateScript = preload("res://shared/runtime/floor_contact_state.gd")
const MobilePhysicsAdapterScript = preload("res://mobile/logic/mobile_physics_adapter.gd")
const MobilePhysicsStateScript = preload("res://mobile/logic/mobile_physics_state.gd")
const MobileMovementResultScript = preload("res://mobile/controls/mobile_movement_result.gd")
const MobilePresentationScript = preload("res://mobile/presentation/mobile_presentation.gd")
const StatusControllerScript = preload("res://mobile/status/status_controller.gd")
const MobileTraversalScript = preload("res://mobile/logic/mobile_traversal.gd")

const GIZMO_BODY := Color(0.58, 0.85, 1.0, 0.92)
const GIZMO_BODY_FILL := Color(0.58, 0.85, 1.0, 0.14)
const GIZMO_HIT_BODY := Color(0.42, 0.95, 0.55, 0.90)
const GIZMO_HIT_CORE := Color(1.0, 0.42, 0.42, 0.95)
const GIZMO_CANNON := Color(0.95, 0.82, 0.36, 0.95)
const GIZMO_STATUS := Color(0.84, 0.60, 1.0, 0.95)
const GIZMO_FACING := Color(0.94, 0.94, 0.94, 0.95)

signal status_view_states_changed(view_states: Array)

var _mobile_def: MobileDefinition
var _editor_show_gizmos_value: bool = true
var _editor_show_labels_value: bool = true
var _editor_show_body_shape_value: bool = true
var _editor_show_hit_zones_value: bool = true
var _editor_show_cannon_mount_value: bool = true
var _editor_show_status_anchor_value: bool = true
var _editor_show_facing_arrow_value: bool = true
var _editor_show_traversal_overlay_value: bool = false

@export var mobile_def: MobileDefinition:
	get:
		return _mobile_def
	set(value):
		_mobile_def = value
		if is_inside_tree():
			_apply_mobile_definition_runtime()
		_on_editor_authoring_changed()

@export_group("Editor Gizmos")
@export var editor_show_gizmos: bool = true:
	get:
		return _editor_show_gizmos_value
	set(value):
		_editor_show_gizmos_value = value
		_on_editor_authoring_changed()

@export var editor_show_labels: bool = true:
	get:
		return _editor_show_labels_value
	set(value):
		_editor_show_labels_value = value
		_on_editor_authoring_changed()

@export var editor_show_body_shape: bool = true:
	get:
		return _editor_show_body_shape_value
	set(value):
		_editor_show_body_shape_value = value
		_on_editor_authoring_changed()

@export var editor_show_hit_zones: bool = true:
	get:
		return _editor_show_hit_zones_value
	set(value):
		_editor_show_hit_zones_value = value
		_on_editor_authoring_changed()

@export var editor_show_cannon_mount: bool = true:
	get:
		return _editor_show_cannon_mount_value
	set(value):
		_editor_show_cannon_mount_value = value
		_on_editor_authoring_changed()

@export var editor_show_status_anchor: bool = true:
	get:
		return _editor_show_status_anchor_value
	set(value):
		_editor_show_status_anchor_value = value
		_on_editor_authoring_changed()

@export var editor_show_facing_arrow: bool = true:
	get:
		return _editor_show_facing_arrow_value
	set(value):
		_editor_show_facing_arrow_value = value
		_on_editor_authoring_changed()

@export var editor_show_traversal_overlay: bool = false:
	get:
		return _editor_show_traversal_overlay_value
	set(value):
		_editor_show_traversal_overlay_value = value
		_on_editor_authoring_changed()

@onready var stat_container: StatContainer = $StatContainer
@onready var cannon: Cannon = $Cannon
@onready var body: AnimatedSprite2D = $Body
@onready var barrel: AnimatedSprite2D = $Cannon/BarrelPivot/Barrel
@onready var body_zone: Area2D = $Hitbox/Body
@onready var core_zone: Area2D = $Hitbox/Core
@onready var collision_shape: CollisionShape2D = $Shape
@onready var status_badge_container: Control = $StatusBadgeContainer

const MOVE_EPSILON := 2.0

var combatant_id: String = ""
var team_index: int = -1
var status_controller: StatusController
var _controller: MobileController
var _physics_adapter: MobilePhysicsAdapter
var _physics_state: MobilePhysicsState
var _presentation: MobilePresentation
var _fallback_facing_direction: int = 1

var facing_direction: int:
	get:
		if _physics_state == null:
			return _fallback_facing_direction
		return _physics_state.facing_direction
	set(value):
		var normalized := -1 if value < 0 else 1
		_fallback_facing_direction = normalized
		if _physics_state != null:
			_physics_state.facing_direction = normalized
		if _presentation != null:
			_presentation.apply_facing(normalized)
		if cannon != null:
			cannon.facing_direction = normalized
		_on_editor_authoring_changed()

func _ready() -> void:
	_initialize_runtime_state()
	_apply_mobile_definition_runtime()
	_on_editor_authoring_changed()

func _apply_mobile_definition_runtime() -> void:
	if mobile_def == null:
		_on_editor_authoring_changed()
		return
	_setup_status_runtime()
	_setup_presentation_runtime()
	if status_badge_container != null:
		status_badge_container.setup(self)
		status_badge_container.position = get_editor_status_anchor_position()
	_setup_cannon_runtime()
	_apply_entity_definition()
	_connect_animation_signals()
	if stat_container != null and not stat_container.died.is_connected(_on_died):
		stat_container.died.connect(_on_died)
	if _presentation != null:
		_presentation.play_idle()
		_presentation.apply_facing(facing_direction)
	_on_editor_authoring_changed()

func _initialize_runtime_state() -> void:
	collision_mask = 1
	_update_floor_settings()
	_physics_state = MobilePhysicsStateScript.new(velocity, true, false, _fallback_facing_direction, false, false, false)
	_physics_adapter = MobilePhysicsAdapterScript.new(
		Callable(self, "_physics_test_move"),
		Callable(self, "_physics_move_and_slide"),
		Callable(self, "_physics_apply_floor_snap"),
		Callable(self, "_physics_build_floor_contact_state"),
		safe_margin
	)

func _setup_status_runtime() -> void:
	if stat_container == null:
		return
	stat_container.stat_def = mobile_def.stat_def
	if status_controller == null:
		status_controller = StatusControllerScript.new()
		status_controller.setup(stat_container)
		if not status_controller.statuses_changed.is_connected(_on_statuses_changed):
			status_controller.statuses_changed.connect(_on_statuses_changed)

func _setup_presentation_runtime() -> void:
	if _presentation == null:
		_presentation = MobilePresentationScript.new()
	_presentation.setup(body, barrel, mobile_def)

func _setup_cannon_runtime() -> void:
	if cannon == null:
		return
	cannon.position = mobile_def.cannon_mount_offset
	cannon.cannon_def = mobile_def.cannon_def
	cannon.facing_direction = facing_direction
	if cannon.firing_mechanism != null:
		cannon.firing_mechanism.setup(
			cannon,
			mobile_def.cannon_def,
			mobile_def.shot_1,
			&"shot_1"
		)

func _connect_animation_signals() -> void:
	if stat_container != null and not stat_container.hit.is_connected(_on_hit):
		stat_container.hit.connect(_on_hit)
	if body != null and not body.animation_finished.is_connected(_on_body_animation_finished):
		body.animation_finished.connect(_on_body_animation_finished)
	if barrel != null and not barrel.animation_finished.is_connected(_on_barrel_animation_finished):
		barrel.animation_finished.connect(_on_barrel_animation_finished)

func bind_controller(controller: MobileController) -> void:
	if controller == null:
		return
	_controller = controller
	controller.charging_started.connect(_on_started_charging)
	controller.charge_canceled.connect(_on_charge_canceled)
	controller.fired.connect(_on_fired)
	if not controller.activated.is_connected(_on_controller_activity_changed):
		controller.activated.connect(_on_controller_activity_changed)
	if not controller.deactivated.is_connected(_on_controller_activity_changed):
		controller.deactivated.connect(_on_controller_activity_changed)
	if status_badge_container != null:
		status_badge_container.bind_controller(controller)
	_sync_status_presentation()

func get_status_view_states() -> Array:
	if status_controller == null:
		return []
	return status_controller.get_status_view_states()

func _refresh_status_badges() -> void:
	if status_badge_container != null:
		status_badge_container.refresh()

func _on_controller_activity_changed(_controller_ref: MobileController) -> void:
	_sync_status_presentation()

func _on_statuses_changed() -> void:
	_sync_status_presentation()

func _emit_status_view_states_changed() -> void:
	status_view_states_changed.emit(get_status_view_states())

func _sync_status_presentation() -> void:
	_emit_status_view_states_changed()
	_refresh_status_badges()

func step_locomotion(move_direction: int, remaining_thrust: float, delta: float) -> MobileMovementResult:
	if mobile_def == null or _physics_state == null:
		return _build_movement_result(0.0, false, false, 0.0, false, facing_direction)

	_update_floor_settings()
	var intended_move_direction: int = clampi(move_direction, -1, 1)
	var previous_x: float = global_position.x
	var previous_vertical_speed: float = _physics_state.velocity.y
	var was_initialized: bool = _physics_state.locomotion_initialized
	var was_grounded: bool = _physics_state.grounded if _physics_state.locomotion_initialized else false

	_physics_state = MobileLocomotionScript.prepare_motion(
		_physics_state,
		mobile_def,
		intended_move_direction,
		remaining_thrust,
		delta
	)
	facing_direction = _physics_state.facing_direction
	velocity = _physics_state.velocity

	var step_attempted: bool = false
	var step_succeeded: bool = false
	if MobileTraversalScript.can_attempt_step_up(_physics_state, mobile_def, intended_move_direction, remaining_thrust, delta):
		step_attempted = true
		var step_offset: Vector2 = MobileTraversalScript.try_step_up(
			global_transform,
			Vector2(velocity.x * delta, 0.0),
			mobile_def,
			_physics_adapter,
			floor_snap_length,
			get_max_walkable_slope_radians()
		)
		if step_offset != Vector2.ZERO:
			global_position += step_offset
			_physics_adapter.apply_floor_snap()
			step_succeeded = true

	_physics_adapter.move_body()

	var floor_contact: FloorContactState = _physics_adapter.get_floor_contact_state()
	var grounded: bool = floor_contact.grounded if floor_contact != null else false
	_physics_state = MobileLocomotionScript.finalize_motion(
		_physics_state,
		velocity,
		grounded,
		MOVE_EPSILON,
		step_attempted,
		step_succeeded
	)
	var spent: float = MobileLocomotionScript.compute_horizontal_spend(
		remaining_thrust,
		intended_move_direction,
		grounded,
		previous_x,
		global_position.x
	)
	var took_support_loss: bool = MobileLocomotionScript.took_support_loss(
		was_initialized,
		was_grounded,
		grounded
	)
	var landing_speed: float = MobileLocomotionScript.compute_landing_speed(
		was_initialized,
		was_grounded,
		grounded,
		previous_vertical_speed
	)
	_apply_fall_damage(landing_speed)
	_presentation.update_locomotion_animation(_physics_state.grounded, _physics_state.moving)

	return _build_movement_result(
		spent,
		_physics_state.grounded,
		_physics_state.moving,
		landing_speed,
		took_support_loss,
		facing_direction
	)

func get_shot_pattern(slot: StringName) -> ShotPattern:
	if mobile_def == null:
		return null
	match slot:
		&"shot_1":
			return mobile_def.shot_1
		&"shot_2":
			return mobile_def.shot_2
		&"shot_ss":
			return mobile_def.shot_ss
		_:
			return mobile_def.shot_1
			
func is_grounded() -> bool:
	if _physics_state == null:
		return true
	return _physics_state.grounded if _physics_state.locomotion_initialized else true

func is_stationary_for_actions() -> bool:
	return MobileLocomotionScript.is_stationary_for_actions(_physics_state, MOVE_EPSILON)

func get_max_walkable_slope_radians() -> float:
	return MobileTraversalScript.get_max_walkable_slope_radians(mobile_def)

func is_surface_walkable(normal: Vector2) -> bool:
	return MobileTraversalScript.is_surface_walkable(normal, get_max_walkable_slope_radians())

func get_current_floor_angle() -> float:
	if not _is_on_walkable_floor():
		return 0.0
	return get_floor_angle(Vector2.UP)

func get_traversal_debug_text() -> String:
	var angle_deg := rad_to_deg(get_current_floor_angle())
	var walkable := _is_on_walkable_floor()
	if _presentation == null:
		return "traversal: unavailable"
	return _presentation.build_traversal_debug_text(_physics_state, mobile_def, angle_deg, walkable)

func get_editor_cannon_mount_position() -> Vector2:
	if cannon != null:
		return cannon.position
	if mobile_def != null:
		return mobile_def.cannon_mount_offset
	return Vector2.ZERO

func get_editor_status_anchor_position() -> Vector2:
	if mobile_def == null:
		return Vector2(0.0, -18.0)
	return Vector2(0.0, -mobile_def.body_size.y * 0.9 - 18.0)

func get_editor_hit_zone_snapshot() -> Dictionary:
	return {
		"body_zone_radius": mobile_def.body_zone_radius if mobile_def != null else 0.0,
		"core_zone_radius": mobile_def.core_zone_radius if mobile_def != null else 0.0,
		"core_zone_offset": mobile_def.core_zone_offset if mobile_def != null else Vector2.ZERO,
	}

func get_debug_snapshot() -> Dictionary:
	var hit_zones := get_editor_hit_zone_snapshot()
	return {
		"name": mobile_def.name if mobile_def != null else name,
		"body_size": mobile_def.body_size if mobile_def != null else Vector2.ZERO,
		"body_zone_radius": hit_zones.body_zone_radius,
		"core_zone_radius": hit_zones.core_zone_radius,
		"core_zone_offset": hit_zones.core_zone_offset,
		"cannon_mount_offset": get_editor_cannon_mount_position(),
		"status_anchor_position": get_editor_status_anchor_position(),
		"facing_direction": facing_direction,
		"grounded": is_grounded(),
		"traversal_debug_text": get_traversal_debug_text(),
		"has_cannon": cannon != null,
		"has_mobile_definition": mobile_def != null,
	}

func _update_floor_settings() -> void:
	if mobile_def == null:
		floor_snap_length = 0.0
		floor_max_angle = 0.0
		return
	floor_snap_length = mobile_def.floor_snap_length
	floor_max_angle = get_max_walkable_slope_radians()

func _build_movement_result(
	horizontal_distance_spent: float,
	grounded: bool,
	moving: bool,
	landing_speed: float,
	took_support_loss: bool,
	result_facing_direction: int
) -> MobileMovementResult:
	return MobileMovementResultScript.new(
		horizontal_distance_spent,
		grounded,
		moving,
		landing_speed,
		took_support_loss,
		result_facing_direction
	)

func _apply_entity_definition() -> void:
	if mobile_def == null:
		_on_editor_authoring_changed()
		return
	var body_shape = collision_shape.shape
	if body_shape is RectangleShape2D:
		(body_shape as RectangleShape2D).size = mobile_def.body_size
	elif body_shape is CapsuleShape2D:
		var capsule := body_shape as CapsuleShape2D
		capsule.radius = mobile_def.body_size.x * 0.5
		capsule.height = maxf(0.0, mobile_def.body_size.y - mobile_def.body_size.x)

	var body_zone_shape = body_zone.get_node("Silhouette").shape
	if body_zone_shape is CircleShape2D:
		(body_zone_shape as CircleShape2D).radius = mobile_def.body_zone_radius

	core_zone.position = mobile_def.core_zone_offset
	var core_shape = core_zone.get_node("Weakpoint").shape
	if core_shape is CircleShape2D:
		(core_shape as CircleShape2D).radius = mobile_def.core_zone_radius
	if status_badge_container != null:
		status_badge_container.position = get_editor_status_anchor_position()
	_on_editor_authoring_changed()

func _on_started_charging() -> void:
	_presentation.on_started_charging()

func _on_charge_canceled() -> void:
	_presentation.on_charge_canceled(_physics_state.grounded, _physics_state.moving)

func _on_fired(_event: ShotEvent) -> void:
	_presentation.on_fired()

func _on_hit() -> void:
	_presentation.on_hit()

func _on_body_animation_finished() -> void:
	match _presentation.handle_body_animation_finished():
		MobilePresentationScript.BodyAnimationAction.RESTORE_LOCOMOTION:
			_presentation.update_locomotion_animation(_physics_state.grounded, _physics_state.moving)
		MobilePresentationScript.BodyAnimationAction.FREE_OWNER:
			queue_free()
		_:
			pass

func _on_barrel_animation_finished() -> void:
	_presentation.handle_barrel_animation_finished()

func _on_died() -> void:
	_presentation.on_died()

func _apply_fall_damage(landing_speed: float) -> void:
	if stat_container == null:
		return
	var damage := MobileDamageRulesScript.compute_fall_damage(
		mobile_def,
		landing_speed,
		stat_container.get_stat("weight")
	)
	if damage > 0.0:
		stat_container.take_damage(damage)

func _is_on_walkable_floor() -> bool:
	if not is_on_floor():
		return false
	return is_surface_walkable(get_floor_normal())

func _physics_test_move(
	test_transform: Transform2D,
	motion: Vector2,
	collision: KinematicCollision2D = null,
	margin: float = 0.08,
	recovery_as_collision: bool = true
) -> bool:
	return test_move(test_transform, motion, collision, margin, recovery_as_collision)

func _physics_move_and_slide() -> void:
	move_and_slide()

func _physics_apply_floor_snap() -> void:
	apply_floor_snap()

func _physics_build_floor_contact_state() -> FloorContactState:
	if not _is_on_walkable_floor():
		return FloorContactStateScript.new(false, Vector2.ZERO, 0.0)
	return FloorContactStateScript.new(true, get_floor_normal(), get_floor_angle(Vector2.UP))

func _draw() -> void:
	if not Engine.is_editor_hint() or not _editor_show_gizmos_value:
		return
	_draw_body_shape_gizmo()
	_draw_hit_zone_gizmos()
	_draw_cannon_mount_gizmo()
	_draw_status_anchor_gizmo()
	_draw_facing_arrow_gizmo()
	_draw_labels()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if mobile_def == null:
		warnings.append("Mobile requires a MobileDefinition.")
		return warnings
	if mobile_def.cannon_def == null:
		warnings.append("MobileDefinition is missing a CannonDefinition.")
	return warnings

func _draw_body_shape_gizmo() -> void:
	if not _editor_show_body_shape_value or collision_shape == null or collision_shape.shape == null:
		return
	var shape := collision_shape.shape
	if shape is RectangleShape2D:
		var rect_shape := shape as RectangleShape2D
		var rect := Rect2(-rect_shape.size * 0.5, rect_shape.size)
		draw_rect(rect, GIZMO_BODY_FILL, true)
		draw_rect(rect, GIZMO_BODY, false, 2.0)
	elif shape is CapsuleShape2D:
		var capsule := shape as CapsuleShape2D
		var radius := capsule.radius
		var half_height := capsule.height * 0.5
		var top_center := Vector2(0.0, -half_height)
		var bottom_center := Vector2(0.0, half_height)
		draw_circle(top_center, radius, GIZMO_BODY_FILL)
		draw_circle(bottom_center, radius, GIZMO_BODY_FILL)
		draw_rect(Rect2(Vector2(-radius, -half_height), Vector2(radius * 2.0, capsule.height)), GIZMO_BODY_FILL, true)
		draw_arc(top_center, radius, 0.0, TAU, 24, GIZMO_BODY, 2.0)
		draw_arc(bottom_center, radius, 0.0, TAU, 24, GIZMO_BODY, 2.0)
		draw_line(top_center + Vector2(-radius, 0.0), bottom_center + Vector2(-radius, 0.0), GIZMO_BODY, 2.0)
		draw_line(top_center + Vector2(radius, 0.0), bottom_center + Vector2(radius, 0.0), GIZMO_BODY, 2.0)

func _draw_hit_zone_gizmos() -> void:
	if not _editor_show_hit_zones_value or mobile_def == null:
		return
	draw_arc(Vector2.ZERO, mobile_def.body_zone_radius, 0.0, TAU, 32, GIZMO_HIT_BODY, 2.0)
	draw_arc(mobile_def.core_zone_offset, mobile_def.core_zone_radius, 0.0, TAU, 24, GIZMO_HIT_CORE, 2.0)
	draw_line(mobile_def.core_zone_offset + Vector2(-6.0, 0.0), mobile_def.core_zone_offset + Vector2(6.0, 0.0), GIZMO_HIT_CORE, 2.0)
	draw_line(mobile_def.core_zone_offset + Vector2(0.0, -6.0), mobile_def.core_zone_offset + Vector2(0.0, 6.0), GIZMO_HIT_CORE, 2.0)

func _draw_cannon_mount_gizmo() -> void:
	if not _editor_show_cannon_mount_value:
		return
	var mount := get_editor_cannon_mount_position()
	draw_circle(mount, 4.0, GIZMO_CANNON)
	draw_line(mount + Vector2(-8.0, 0.0), mount + Vector2(8.0, 0.0), GIZMO_CANNON, 2.0)
	draw_line(mount + Vector2(0.0, -8.0), mount + Vector2(0.0, 8.0), GIZMO_CANNON, 2.0)

func _draw_status_anchor_gizmo() -> void:
	if not _editor_show_status_anchor_value:
		return
	var anchor := get_editor_status_anchor_position()
	draw_circle(anchor, 4.0, GIZMO_STATUS)
	draw_line(anchor + Vector2(-6.0, -6.0), anchor + Vector2(6.0, 6.0), GIZMO_STATUS, 2.0)
	draw_line(anchor + Vector2(-6.0, 6.0), anchor + Vector2(6.0, -6.0), GIZMO_STATUS, 2.0)

func _draw_facing_arrow_gizmo() -> void:
	if not _editor_show_facing_arrow_value:
		return
	var arrow_end := Vector2(30.0 * facing_direction, 0.0)
	draw_line(Vector2.ZERO, arrow_end, GIZMO_FACING, 2.0)
	draw_line(arrow_end, arrow_end + Vector2(-8.0 * facing_direction, -6.0), GIZMO_FACING, 2.0)
	draw_line(arrow_end, arrow_end + Vector2(-8.0 * facing_direction, 6.0), GIZMO_FACING, 2.0)

func _draw_labels() -> void:
	if not _editor_show_labels_value:
		return
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var lines := [
		"%s facing=%d" % [mobile_def.name if mobile_def != null else name, facing_direction],
		"body=%s mount=%s" % [str(mobile_def.body_size if mobile_def != null else Vector2.ZERO), str(get_editor_cannon_mount_position())],
		"core=%s @ %s" % [
			str(mobile_def.core_zone_radius if mobile_def != null else 0.0),
			str(mobile_def.core_zone_offset if mobile_def != null else Vector2.ZERO)
		]
	]
	if _editor_show_traversal_overlay_value:
		lines.append(get_traversal_debug_text())
	var origin := Vector2(18.0, -24.0)
	for index in lines.size():
		draw_string(font, origin + Vector2(0.0, float(index) * 16.0), lines[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GIZMO_BODY)

func _on_editor_authoring_changed() -> void:
	if not is_inside_tree():
		return
	queue_redraw()
	update_configuration_warnings()
