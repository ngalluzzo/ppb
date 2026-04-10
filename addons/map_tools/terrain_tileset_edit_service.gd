@tool
class_name TerrainTilesetEditService
extends RefCounted

static func capture_cell_state(tile_set: TileSet, source_id: int, atlas_coords: Vector2i) -> Dictionary:
	var source := _get_source(tile_set, source_id)
	if source == null:
		return {}
	var tile_data := source.get_tile_data(atlas_coords, 0)
	if tile_data == null:
		return {}
	var polygons: Array[PackedVector2Array] = []
	var polygon_count := tile_data.get_collision_polygons_count(0)
	for polygon_index in polygon_count:
		polygons.append(tile_data.get_collision_polygon_points(0, polygon_index))
	return {
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"tile_definition": tile_data.get_custom_data("tile_def") as TileDefinition,
		"collision_polygons": polygons,
	}

static func apply_cell_states(tile_set: TileSet, states: Array[Dictionary]) -> void:
	if tile_set == null:
		return
	for state in states:
		var source := _get_source(tile_set, int(state.get("source_id", -1)))
		if source == null:
			continue
		var atlas_coords: Vector2i = state.get("atlas_coords", Vector2i.ZERO)
		var tile_data := source.get_tile_data(atlas_coords, 0)
		if tile_data == null:
			continue
		tile_data.set_custom_data("tile_def", state.get("tile_definition", null))
		var polygons: Array = state.get("collision_polygons", [])
		tile_data.set_collision_polygons_count(0, polygons.size())
		for polygon_index in polygons.size():
			tile_data.set_collision_polygon_points(0, polygon_index, polygons[polygon_index])
	tile_set.emit_changed()

static func with_tile_definition(state: Dictionary, tile_definition: TileDefinition) -> Dictionary:
	var clone := state.duplicate(true)
	clone["tile_definition"] = tile_definition
	return clone

static func with_full_collision(state: Dictionary, tile_size: Vector2i, enabled: bool) -> Dictionary:
	var clone := state.duplicate(true)
	if not enabled:
		clone["collision_polygons"] = []
		return clone
	var half := Vector2(tile_size) * 0.5
	clone["collision_polygons"] = [PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])]
	return clone

static func _get_source(tile_set: TileSet, source_id: int) -> TileSetAtlasSource:
	if tile_set == null or source_id < 0 or not tile_set.has_source(source_id):
		return null
	return tile_set.get_source(source_id) as TileSetAtlasSource

