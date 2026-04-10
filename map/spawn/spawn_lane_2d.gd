@tool
class_name SpawnLane2D
extends Node2D

const PREVIEW_FILL := Color(0.53, 0.76, 0.97, 0.12)
const PREVIEW_OUTLINE := Color(0.53, 0.76, 0.97, 0.95)
const PREVIEW_TEAM_A := Color(0.46, 0.86, 0.42, 0.95)
const PREVIEW_TEAM_B := Color(0.97, 0.39, 0.39, 0.95)

@export var team_index: int = 0:
	set(value):
		team_index = value
		_on_authoring_changed()

@export var facing_direction: int = 1:
	set(value):
		facing_direction = value
		_on_authoring_changed()

@export_range(32.0, 2048.0, 1.0, "or_greater") var lane_width: float = 320.0:
	set(value):
		lane_width = maxf(32.0, value)
		_on_authoring_changed()

@export_range(16.0, 2048.0, 1.0, "or_greater") var sample_height: float = 192.0:
	set(value):
		sample_height = maxf(16.0, value)
		_on_authoring_changed()

@export var camera_focus_offset: Vector2 = Vector2.ZERO:
	set(value):
		camera_focus_offset = value
		_on_authoring_changed()

func _ready() -> void:
	queue_redraw()
	update_configuration_warnings()

func get_spawn_position(terrain: Terrain) -> Vector2:
	if terrain == null:
		return get_camera_target()

	var sample_y := global_position.y - sample_height * 0.5
	for _attempt in 10:
		var candidate := Vector2(
			randf_range(global_position.x - lane_width * 0.5, global_position.x + lane_width * 0.5),
			sample_y
		)
		var surface := terrain.find_surface_below(candidate)
		if surface != candidate:
			return surface

	return get_camera_target()

func get_camera_target() -> Vector2:
	return global_position + camera_focus_offset

func get_lane_rect() -> Rect2:
	return Rect2(
		Vector2(-lane_width * 0.5, -sample_height * 0.5),
		Vector2(lane_width, sample_height)
	)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var lane_rect := get_lane_rect()
	var accent := _get_accent_color()

	draw_rect(lane_rect, PREVIEW_FILL, true)
	draw_rect(lane_rect, accent, false, 2.0)
	draw_line(
		Vector2(lane_rect.position.x, 0),
		Vector2(lane_rect.end.x, 0),
		accent,
		2.0
	)

	var arrow_start := Vector2.ZERO
	var arrow_end := Vector2(facing_direction * 48.0, 0)
	draw_line(arrow_start, arrow_end, accent, 3.0)
	draw_line(arrow_end, arrow_end + Vector2(-facing_direction * 12.0, -8.0), accent, 3.0)
	draw_line(arrow_end, arrow_end + Vector2(-facing_direction * 12.0, 8.0), accent, 3.0)

	var camera_marker := camera_focus_offset
	draw_circle(camera_marker, 6.0, accent)

	var font := ThemeDB.fallback_font
	if font != null:
		draw_string(
			font,
			Vector2(lane_rect.position.x, lane_rect.position.y - 10.0),
			"Team %d" % team_index,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			accent
		)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if team_index < 0:
		warnings.append("SpawnLane2D requires a non-negative team_index.")
	if facing_direction != -1 and facing_direction != 1:
		warnings.append("SpawnLane2D facing_direction must be -1 or 1.")

	var battle_map := _find_battle_map()
	if battle_map != null and battle_map.has_method("count_spawn_lanes_for_team"):
		var duplicate_count: int = battle_map.count_spawn_lanes_for_team(team_index)
		if duplicate_count > 1:
			warnings.append("Another SpawnLane2D already uses team_index %d." % team_index)

	return warnings

func _get_accent_color() -> Color:
	if team_index == 0:
		return PREVIEW_TEAM_A
	if team_index == 1:
		return PREVIEW_TEAM_B
	return PREVIEW_OUTLINE

func _find_battle_map() -> Node:
	var node := get_parent()
	while node != null:
		if node.has_method("notify_authoring_changed") and node.has_method("count_spawn_lanes_for_team"):
			return node
		node = node.get_parent()
	return null

func _on_authoring_changed() -> void:
	queue_redraw()
	update_configuration_warnings()

	var battle_map := _find_battle_map()
	if battle_map != null:
		battle_map.call_deferred("notify_authoring_changed")
