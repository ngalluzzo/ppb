@tool
class_name BattleMap
extends Node2D

const BattleViewConfigScript = preload("res://battle/battle_view_config.gd")
const MapSizePresetsScript = preload("res://map/map_size_presets.gd")

const WORLD_FILL := Color(0.30, 0.70, 0.98, 0.07)
const WORLD_OUTLINE := Color(0.30, 0.70, 0.98, 0.95)
const CAMERA_OUTLINE := Color(0.99, 0.84, 0.36, 0.95)
const TEAM_A_COLOR := Color(0.46, 0.86, 0.42, 0.85)
const TEAM_B_COLOR := Color(0.97, 0.39, 0.39, 0.85)

@export var world_bounds: Rect2 = MapSizePresetsScript.get_world_bounds(0):
	set(value):
		world_bounds = value
		_on_authoring_changed()

@export var camera_bounds: Rect2 = MapSizePresetsScript.get_camera_bounds(0):
	set(value):
		camera_bounds = value
		_on_authoring_changed()

@onready var terrain: Terrain = $Terrain
@onready var spawn_lanes_root: Node2D = $SpawnLanes

func _ready() -> void:
	notify_authoring_changed()

func setup() -> void:
	notify_authoring_changed()

func get_world_bounds() -> Rect2:
	return world_bounds

func get_camera_bounds() -> Rect2:
	return camera_bounds

func get_terrain() -> Terrain:
	return terrain

func get_spawn_lane(team_index: int) -> SpawnLane2D:
	for lane in _get_spawn_lanes():
		if lane.team_index == team_index:
			return lane
	return null

func get_start_camera_target(team_index: int) -> Vector2:
	var lane := get_spawn_lane(team_index)
	if lane == null:
		return global_position
	return lane.get_camera_target()

func count_spawn_lanes_for_team(team_index: int) -> int:
	var count := 0
	for lane in _get_spawn_lanes():
		if lane.team_index == team_index:
			count += 1
	return count

func notify_authoring_changed() -> void:
	queue_redraw()
	update_configuration_warnings()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_rect(world_bounds, WORLD_FILL, true)
	draw_rect(world_bounds, WORLD_OUTLINE, false, 4.0)
	draw_rect(camera_bounds, CAMERA_OUTLINE, false, 3.0)
	_draw_center_axes()
	_draw_camera_preview(0, TEAM_A_COLOR)
	_draw_camera_preview(1, TEAM_B_COLOR)
	_draw_labels()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	var terrain_node := _get_terrain_node()
	if terrain_node == null:
		warnings.append("BattleMap requires a Terrain child node.")

	var lanes := _get_spawn_lanes()
	if get_spawn_lane(0) == null:
		warnings.append("BattleMap requires a Team A spawn lane (team_index 0).")
	if get_spawn_lane(1) == null:
		warnings.append("BattleMap requires a Team B spawn lane (team_index 1).")

	var team_counts := {}
	for lane in lanes:
		team_counts[lane.team_index] = int(team_counts.get(lane.team_index, 0)) + 1

		var lane_center := to_local(lane.global_position)
		if not world_bounds.has_point(lane_center):
			warnings.append("%s sits outside world_bounds." % lane.name)

		var start_camera_rect := _get_start_camera_rect_local(lane)
		if not _rect_contains_rect(camera_bounds, start_camera_rect):
			warnings.append("%s start camera view extends outside camera_bounds." % lane.name)

	for team_index in team_counts.keys():
		if int(team_counts[team_index]) > 1:
			warnings.append("Multiple spawn lanes use team_index %d." % int(team_index))

	return warnings

func _draw_center_axes() -> void:
	var center := world_bounds.get_center()
	draw_line(
		Vector2(center.x, world_bounds.position.y),
		Vector2(center.x, world_bounds.end.y),
		CAMERA_OUTLINE,
		2.0
	)
	draw_line(
		Vector2(world_bounds.position.x, center.y),
		Vector2(world_bounds.end.x, center.y),
		CAMERA_OUTLINE,
		2.0
	)

func _draw_camera_preview(team_index: int, color: Color) -> void:
	var lane := get_spawn_lane(team_index)
	if lane == null:
		return

	var preview_rect := _get_start_camera_rect_local(lane)
	draw_rect(preview_rect, color, false, 2.0)

	var target := to_local(lane.get_camera_target())
	draw_circle(target, 6.0, color)

	var font := ThemeDB.fallback_font
	if font != null:
		draw_string(
			font,
			preview_rect.position + Vector2(8.0, 20.0),
			"Team %d Start Camera" % team_index,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			color
		)

func _draw_labels() -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return

	draw_string(
		font,
		world_bounds.position + Vector2(12.0, 24.0),
		"WORLD",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		WORLD_OUTLINE
	)
	draw_string(
		font,
		camera_bounds.position + Vector2(12.0, 24.0),
		"CAMERA",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		CAMERA_OUTLINE
	)

func _get_start_camera_rect_local(lane: SpawnLane2D) -> Rect2:
	var visible_size := BattleViewConfigScript.get_visible_world_size()
	var local_target := to_local(lane.get_camera_target())
	return Rect2(local_target - visible_size * 0.5, visible_size)

func _get_spawn_lanes() -> Array[SpawnLane2D]:
	var lanes: Array[SpawnLane2D] = []
	var root := _get_spawn_lanes_root()
	if root == null:
		return lanes

	for child in root.get_children():
		var lane := child as SpawnLane2D
		if lane != null:
			lanes.append(lane)
	return lanes

func _get_terrain_node() -> Terrain:
	if is_instance_valid(terrain):
		return terrain
	return get_node_or_null("Terrain") as Terrain

func _get_spawn_lanes_root() -> Node2D:
	if is_instance_valid(spawn_lanes_root):
		return spawn_lanes_root
	return get_node_or_null("SpawnLanes") as Node2D

func _rect_contains_rect(container: Rect2, inner: Rect2) -> bool:
	return (
		inner.position.x >= container.position.x
		and inner.position.y >= container.position.y
		and inner.end.x <= container.end.x
		and inner.end.y <= container.end.y
	)

func _on_authoring_changed() -> void:
	queue_redraw()
	update_configuration_warnings()
