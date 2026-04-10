@tool
class_name TerrainValidationService
extends RefCounted

const TerrainValidationIssueScript = preload("res://addons/map_tools/terrain_validation_issue.gd")
const BattleViewConfigScript = preload("res://battle/battle_view_config.gd")

func validate_tileset(tile_set: TileSet) -> Array[TerrainValidationIssue]:
	var issues: Array[TerrainValidationIssue] = []
	if tile_set == null:
		return issues
	for source_index in tile_set.get_source_count():
		var source_id := tile_set.get_source_id(source_index)
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		if source == null:
			continue
		for tile_index in source.get_tiles_count():
			var atlas_coords: Vector2i = source.get_tile_id(tile_index)
			var tile_data := source.get_tile_data(atlas_coords, 0)
			if tile_data == null:
				continue
			var tile_definition = tile_data.get_custom_data("tile_def") as TileDefinition
			if tile_definition == null:
				issues.append(_make_issue(
					TerrainValidationIssue.Severity.ERROR,
					&"missing_tile_definition",
					&"tileset_cell",
					"Tile %s in source %d is missing tile_def metadata." % [atlas_coords, source_id],
					source_id,
					atlas_coords
				))
				continue
			if tile_data.get_collision_polygons_count(0) <= 0:
				issues.append(_make_issue(
					TerrainValidationIssue.Severity.WARNING,
					&"missing_collision",
					&"tileset_cell",
					"Tile %s in source %d has semantic metadata but no collision polygon." % [atlas_coords, source_id],
					source_id,
					atlas_coords
				))
	return issues

func validate_map(battle_map: BattleMap) -> Array[TerrainValidationIssue]:
	var issues: Array[TerrainValidationIssue] = []
	if battle_map == null:
		return issues
	var terrain := battle_map.get_terrain()
	if terrain == null:
		issues.append(_make_issue(
			TerrainValidationIssue.Severity.ERROR,
			&"missing_terrain",
			&"map",
			"BattleMap is missing its Terrain node."
		))
		return issues

	var used_cells := terrain.get_used_cells()
	if used_cells.is_empty():
		issues.append(_make_issue(
			TerrainValidationIssue.Severity.WARNING,
			&"empty_terrain",
			&"map",
			"Terrain has no painted cells."
		))

	for cell in used_cells:
		var center := terrain.to_global(terrain.map_to_local(cell))
		var local_center := battle_map.to_local(center)
		if not battle_map.world_bounds.has_point(local_center):
			var outside_issue := _make_issue(
				TerrainValidationIssue.Severity.WARNING,
				&"terrain_outside_world_bounds",
				&"cell",
				"Terrain cell %s sits outside world_bounds." % [cell]
			)
			outside_issue.cell = cell
			issues.append(outside_issue)
		if terrain.get_tile_definition(cell) == null:
			var semantic_issue := _make_issue(
				TerrainValidationIssue.Severity.ERROR,
				&"map_cell_missing_tile_definition",
				&"cell",
				"Terrain cell %s uses a tile with no tile_def metadata." % [cell]
			)
			semantic_issue.cell = cell
			issues.append(semantic_issue)

	var visible_size := BattleViewConfigScript.get_visible_world_size()
	for team_index in [0, 1]:
		var lane := battle_map.get_spawn_lane(team_index)
		if lane == null:
			issues.append(_make_issue(
				TerrainValidationIssue.Severity.ERROR,
				&"missing_spawn_lane",
				&"map",
				"BattleMap is missing spawn lane for team %d." % team_index
			))
			continue
		var lane_local := battle_map.to_local(lane.global_position)
		if not battle_map.world_bounds.has_point(lane_local):
			var bounds_issue := _make_issue(
				TerrainValidationIssue.Severity.ERROR,
				&"spawn_lane_outside_world_bounds",
				&"spawn_lane",
				"%s sits outside world_bounds." % lane.name
			)
			bounds_issue.node_path = battle_map.get_path_to(lane)
			issues.append(bounds_issue)
		var camera_rect := Rect2(lane.get_camera_target() - visible_size * 0.5, visible_size)
		if not _rect_contains_rect(battle_map.camera_bounds, battle_map.to_local(camera_rect.position), camera_rect.size):
			var camera_issue := _make_issue(
				TerrainValidationIssue.Severity.WARNING,
				&"spawn_camera_outside_bounds",
				&"spawn_lane",
				"%s start camera view extends outside camera_bounds." % lane.name
			)
			camera_issue.node_path = battle_map.get_path_to(lane)
			issues.append(camera_issue)
		var sample_start := lane.global_position + Vector2(0.0, -lane.sample_height * 0.5)
		var ground_hit := terrain.raycast_ground(sample_start, lane.sample_height * 2.0)
		if ground_hit == null or not ground_hit.did_hit:
			var grounding_issue := _make_issue(
				TerrainValidationIssue.Severity.ERROR,
				&"spawn_lane_no_ground",
				&"spawn_lane",
				"%s does not find terrain below its sampling region." % lane.name
			)
			grounding_issue.node_path = battle_map.get_path_to(lane)
			issues.append(grounding_issue)
		var occupied_cell := terrain.local_to_map(terrain.to_local(lane.global_position))
		if terrain.get_cell_source_id(occupied_cell) != -1:
			var embedded_issue := _make_issue(
				TerrainValidationIssue.Severity.WARNING,
				&"spawn_lane_embedded",
				&"spawn_lane",
				"%s origin sits inside painted terrain." % lane.name
			)
			embedded_issue.node_path = battle_map.get_path_to(lane)
			issues.append(embedded_issue)
	return issues

func _rect_contains_rect(container: Rect2, inner_position: Vector2, inner_size: Vector2) -> bool:
	var inner := Rect2(inner_position, inner_size)
	return (
		inner.position.x >= container.position.x
		and inner.position.y >= container.position.y
		and inner.end.x <= container.end.x
		and inner.end.y <= container.end.y
	)

func _make_issue(
	severity: int,
	kind: StringName,
	target_type: StringName,
	message: String,
	source_id: int = -1,
	atlas_coords: Vector2i = Vector2i.ZERO
) -> TerrainValidationIssue:
	var issue: TerrainValidationIssue = TerrainValidationIssueScript.new()
	issue.severity = severity
	issue.kind = kind
	issue.target_type = target_type
	issue.message = message
	issue.source_id = source_id
	issue.atlas_coords = atlas_coords
	return issue

