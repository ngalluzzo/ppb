@tool
class_name Cannon
extends Node2D

const ShotResolverScript = preload("res://weapon/shot/shot_resolver.gd")
const ShotShooterContextScript = preload("res://weapon/shot/shot_shooter_context.gd")

const GIZMO_MOUNT := Color(0.93, 0.87, 0.44, 0.95)
const GIZMO_MUZZLE := Color(0.99, 0.54, 0.32, 0.95)
const GIZMO_AIM := Color(0.45, 0.88, 1.0, 0.95)
const GIZMO_FAN := Color(0.45, 0.88, 1.0, 0.28)
const GIZMO_FAN_OUTLINE := Color(0.45, 0.88, 1.0, 0.75)
const GIZMO_FACING := Color(0.58, 0.95, 0.56, 0.95)

var _resolver: ShotResolver = ShotResolverScript.new()
@export var _cannon_def: CannonDefinition
var _editor_show_gizmos_value: bool = true
var _editor_show_labels_value: bool = true
var _editor_show_angle_fan_value: bool = true
var _editor_show_aim_ray_value: bool = true
var _editor_show_muzzle_marker_value: bool = true
var _editor_show_mount_marker_value: bool = true
var _editor_preview_enabled_value: bool = false
var _editor_preview_shot_pattern_value: ShotPattern
var _editor_preview_power_value: float = 50.0
var _editor_preview_slot_value: StringName = &"shot_1"
var _editor_preview_shooter_id_value: String = "preview_cannon"
var _editor_preview_team_index_value: int = 0
var _editor_preview_facing_direction_value: int = 1

@onready var barrel_pivot: Node2D = $BarrelPivot
@onready var barrel: AnimatedSprite2D = $BarrelPivot/Barrel
@onready var muzzle: Marker2D = $BarrelPivot/Muzzle
@onready var firing_mechanism: FiringMechanism = $FiringMechanism

var _elevation_degrees: float = 45.0
var _facing_direction: int = 1

signal angle_changed(degrees: float)

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

@export var editor_show_angle_fan: bool = true:
	get:
		return _editor_show_angle_fan_value
	set(value):
		_editor_show_angle_fan_value = value
		_on_editor_authoring_changed()

@export var editor_show_aim_ray: bool = true:
	get:
		return _editor_show_aim_ray_value
	set(value):
		_editor_show_aim_ray_value = value
		_on_editor_authoring_changed()

@export var editor_show_muzzle_marker: bool = true:
	get:
		return _editor_show_muzzle_marker_value
	set(value):
		_editor_show_muzzle_marker_value = value
		_on_editor_authoring_changed()

@export var editor_show_mount_marker: bool = true:
	get:
		return _editor_show_mount_marker_value
	set(value):
		_editor_show_mount_marker_value = value
		_on_editor_authoring_changed()

@export_group("Editor Preview")
@export var editor_preview_enabled: bool = false:
	get:
		return _editor_preview_enabled_value
	set(value):
		_editor_preview_enabled_value = value
		_on_editor_authoring_changed()

@export var editor_preview_shot_pattern: ShotPattern:
	get:
		return _editor_preview_shot_pattern_value
	set(value):
		_editor_preview_shot_pattern_value = value
		_on_editor_authoring_changed()

@export var editor_preview_power: float = 50.0:
	get:
		return _editor_preview_power_value
	set(value):
		_editor_preview_power_value = _clamp_preview_power(value)
		_on_editor_authoring_changed()

@export var editor_preview_slot: StringName = &"shot_1":
	get:
		return _editor_preview_slot_value
	set(value):
		_editor_preview_slot_value = value
		_on_editor_authoring_changed()

@export var editor_preview_shooter_id: String = "preview_cannon":
	get:
		return _editor_preview_shooter_id_value
	set(value):
		_editor_preview_shooter_id_value = value.strip_edges() if value != null else "preview_cannon"
		if _editor_preview_shooter_id_value == "":
			_editor_preview_shooter_id_value = "preview_cannon"
		_on_editor_authoring_changed()

@export var editor_preview_team_index: int = 0:
	get:
		return _editor_preview_team_index_value
	set(value):
		_editor_preview_team_index_value = value
		_on_editor_authoring_changed()

@export var editor_preview_facing_direction: int = 1:
	get:
		return _editor_preview_facing_direction_value
	set(value):
		_editor_preview_facing_direction_value = -1 if value < 0 else 1
		_on_editor_authoring_changed()

var cannon_def: CannonDefinition:
	set(value):
		_cannon_def = value
		_apply_definition_layout()
		if value != null:
			set_elevation_degrees(value.initial_angle)
			_editor_preview_power_value = _clamp_preview_power(_editor_preview_power_value if _editor_preview_power_value != 0.0 else value.min_power)
		_on_editor_authoring_changed()
	get:
		return _cannon_def

var elevation_degrees: float:
	get:
		return _elevation_degrees
	set(value):
		set_elevation_degrees(value)

var facing_direction: int:
	get:
		return _facing_direction
	set(value):
		_facing_direction = -1 if value < 0 else 1
		_update_barrel_rotation()
		_on_editor_authoring_changed()

func _ready() -> void:
	_apply_definition_layout()
	_update_barrel_rotation()
	_editor_preview_power_value = _clamp_preview_power(_editor_preview_power_value)
	_on_editor_authoring_changed()

func set_elevation_degrees(value: float) -> void:
	if cannon_def != null:
		_elevation_degrees = clamp(value, cannon_def.min_angle, cannon_def.max_angle)
	else:
		_elevation_degrees = value
	_update_barrel_rotation()
	emit_signal("angle_changed", _elevation_degrees)
	_on_editor_authoring_changed()

func adjust_elevation_degrees(delta: float) -> void:
	set_elevation_degrees(_elevation_degrees + delta)

func get_elevation_degrees() -> float:
	return _elevation_degrees

func get_clamped_elevation_degrees(value: float) -> float:
	if cannon_def == null:
		return value
	return clamp(value, cannon_def.min_angle, cannon_def.max_angle)

func get_aim_rotation_for_degrees(degrees: float) -> float:
	return get_aim_direction_for_degrees(degrees).angle()

func get_aim_direction_for_degrees(degrees: float) -> Vector2:
	var direction: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(-degrees))
	if _facing_direction < 0:
		direction.x *= -1.0
	return direction.normalized()

func get_aim_direction() -> Vector2:
	return get_aim_direction_for_degrees(_elevation_degrees)

func get_muzzle_position() -> Vector2:
	return muzzle.global_position if muzzle != null else global_position

func is_editor_preview_ready() -> bool:
	if not _editor_preview_enabled_value:
		return false
	if cannon_def == null:
		return false
	return _get_editor_preview_pattern() != null

func get_debug_snapshot() -> Dictionary:
	return {
		"name": cannon_def.name if cannon_def != null else name,
		"angle": _elevation_degrees,
		"facing_direction": _facing_direction,
		"muzzle_position": get_muzzle_position(),
		"aim_direction": get_aim_direction(),
		"min_angle": cannon_def.min_angle if cannon_def != null else 0.0,
		"max_angle": cannon_def.max_angle if cannon_def != null else 0.0,
		"preview_enabled": _editor_preview_enabled_value,
		"preview_slot": String(_editor_preview_slot_value),
		"preview_power": _clamp_preview_power(_editor_preview_power_value),
		"has_preview_pattern": _get_editor_preview_pattern() != null,
	}

func build_editor_preview_shot_event(command: FireCommand, weather_controller = null) -> ShotEvent:
	if command == null or not is_editor_preview_ready():
		return null
	var pattern := _get_editor_preview_pattern()
	if pattern == null:
		return null
	var shooter_context := ShotShooterContextScript.new(
		_editor_preview_shooter_id_value,
		_editor_preview_team_index_value,
		_editor_preview_facing_direction_value
	)
	return _resolver.resolve(
		command,
		shooter_context,
		self,
		pattern,
		firing_mechanism._consume_next_shot_id(),
		weather_controller
	)

func _apply_definition_layout() -> void:
	if cannon_def == null:
		_on_editor_authoring_changed()
		return
	if barrel != null:
		barrel.position = cannon_def.barrel_sprite_offset
	if muzzle != null:
		muzzle.position = cannon_def.muzzle_offset
	_on_editor_authoring_changed()

func _update_barrel_rotation() -> void:
	if barrel_pivot == null:
		return
	barrel_pivot.rotation = get_aim_rotation_for_degrees(_elevation_degrees)
	_on_editor_authoring_changed()

func _draw() -> void:
	if not Engine.is_editor_hint() or not _editor_show_gizmos_value:
		return
	_draw_mount_marker()
	_draw_muzzle_marker()
	_draw_angle_fan()
	_draw_aim_ray()
	_draw_facing_indicator()
	_draw_labels()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if cannon_def == null:
		warnings.append("Cannon requires a CannonDefinition.")
	if _editor_preview_enabled_value and _get_editor_preview_pattern() == null:
		warnings.append("Editor preview is enabled but no preview shot pattern is configured.")
	if _editor_preview_facing_direction_value != -1 and _editor_preview_facing_direction_value != 1:
		warnings.append("editor_preview_facing_direction must be -1 or 1.")
	return warnings

func _get_editor_preview_pattern() -> ShotPattern:
	if _editor_preview_shot_pattern_value != null:
		return _editor_preview_shot_pattern_value
	if _editor_preview_enabled_value and firing_mechanism != null:
		return firing_mechanism.get_active_shot_pattern()
	return null

func _clamp_preview_power(value: float) -> float:
	if cannon_def == null:
		return value
	return clampf(value, cannon_def.min_power, cannon_def.max_power)

func _get_aim_length() -> float:
	var offset_length := cannon_def.muzzle_offset.length() if cannon_def != null else 24.0
	return maxf(offset_length + 56.0, 80.0)

func _draw_mount_marker() -> void:
	if not _editor_show_mount_marker_value:
		return
	draw_circle(Vector2.ZERO, 4.0, GIZMO_MOUNT)
	draw_line(Vector2(-8.0, 0.0), Vector2(8.0, 0.0), GIZMO_MOUNT, 2.0)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, 8.0), GIZMO_MOUNT, 2.0)

func _draw_muzzle_marker() -> void:
	if not _editor_show_muzzle_marker_value:
		return
	var muzzle_local := muzzle.position if muzzle != null else Vector2.ZERO
	draw_circle(muzzle_local, 4.0, GIZMO_MUZZLE)
	draw_arc(muzzle_local, 8.0, 0.0, TAU, 24, GIZMO_MUZZLE, 1.5)

func _draw_angle_fan() -> void:
	if not _editor_show_angle_fan_value or cannon_def == null or muzzle == null:
		return
	var muzzle_local := muzzle.position
	var min_dir := get_aim_direction_for_degrees(cannon_def.min_angle)
	var max_dir := get_aim_direction_for_degrees(cannon_def.max_angle)
	var radius := _get_aim_length()
	var points := PackedVector2Array([muzzle_local])
	var step_count := 18
	for index in step_count + 1:
		var t := float(index) / float(step_count)
		var degrees := lerpf(cannon_def.min_angle, cannon_def.max_angle, t)
		points.append(muzzle_local + get_aim_direction_for_degrees(degrees) * radius)
	draw_colored_polygon(points, GIZMO_FAN)
	draw_line(muzzle_local, muzzle_local + min_dir * radius, GIZMO_FAN_OUTLINE, 1.5)
	draw_line(muzzle_local, muzzle_local + max_dir * radius, GIZMO_FAN_OUTLINE, 1.5)
	draw_arc(muzzle_local, radius, min_dir.angle(), max_dir.angle(), 24, GIZMO_FAN_OUTLINE, 1.5)

func _draw_aim_ray() -> void:
	if not _editor_show_aim_ray_value:
		return
	var muzzle_local := muzzle.position if muzzle != null else Vector2.ZERO
	var aim_end := muzzle_local + get_aim_direction() * _get_aim_length()
	draw_line(muzzle_local, aim_end, GIZMO_AIM, 2.5)

func _draw_facing_indicator() -> void:
	var arrow_start := Vector2.ZERO
	var arrow_end := Vector2(24.0 * _facing_direction, 0.0)
	draw_line(arrow_start, arrow_end, GIZMO_FACING, 2.0)
	draw_line(arrow_end, arrow_end + Vector2(-8.0 * _facing_direction, -6.0), GIZMO_FACING, 2.0)
	draw_line(arrow_end, arrow_end + Vector2(-8.0 * _facing_direction, 6.0), GIZMO_FACING, 2.0)

func _draw_labels() -> void:
	if not _editor_show_labels_value:
		return
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var label_color := GIZMO_AIM
	var label_lines := [
		"%s angle=%.1f facing=%d" % [cannon_def.name if cannon_def != null else name, _elevation_degrees, _facing_direction],
		"fan=%.1f..%.1f slot=%s" % [
			cannon_def.min_angle if cannon_def != null else 0.0,
			cannon_def.max_angle if cannon_def != null else 0.0,
			String(_editor_preview_slot_value)
		],
		"preview=%s power=%.1f muzzle=(%.1f, %.1f)" % [
			"on" if _editor_preview_enabled_value else "off",
			_clamp_preview_power(_editor_preview_power_value),
			(muzzle.position.x if muzzle != null else 0.0),
			(muzzle.position.y if muzzle != null else 0.0)
		]
	]
	var label_origin := Vector2(12.0, -18.0)
	for index in label_lines.size():
		draw_string(
			font,
			label_origin + Vector2(0.0, float(index) * 16.0),
			label_lines[index],
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			label_color
		)

func _on_editor_authoring_changed() -> void:
	if not is_inside_tree():
		return
	queue_redraw()
	update_configuration_warnings()
