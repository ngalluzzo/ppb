extends SceneTree

const GrassTileSet = preload("res://terrain/tilesets/grass.tres")
const TerrainTilesetEditServiceScript = preload("res://addons/map_tools/terrain_tileset_edit_service.gd")

func _init() -> void:
	print("--- terrain tileset edit probe ---")

	var tile_set := GrassTileSet.duplicate(true) as TileSet
	assert(tile_set != null)
	assert(tile_set.get_source_count() > 0)

	var source_id := tile_set.get_source_id(0)
	var source := tile_set.get_source(source_id) as TileSetAtlasSource
	assert(source != null)
	assert(source.get_tiles_count() > 0)

	var atlas_coords: Vector2i = source.get_tile_id(0)
	var before := TerrainTilesetEditServiceScript.capture_cell_state(tile_set, source_id, atlas_coords)
	assert(not before.is_empty())
	assert(before.get("tile_definition", null) != null)
	assert((before.get("collision_polygons", []) as Array).size() > 0)

	var cleared_semantic := TerrainTilesetEditServiceScript.with_tile_definition(before, null)
	TerrainTilesetEditServiceScript.apply_cell_states(tile_set, [cleared_semantic])
	var cleared_state := TerrainTilesetEditServiceScript.capture_cell_state(tile_set, source_id, atlas_coords)
	assert(cleared_state.get("tile_definition", "sentinel") == null)

	var cleared_collision := TerrainTilesetEditServiceScript.with_full_collision(cleared_state, tile_set.get_tile_size(), false)
	TerrainTilesetEditServiceScript.apply_cell_states(tile_set, [cleared_collision])
	var no_collision_state := TerrainTilesetEditServiceScript.capture_cell_state(tile_set, source_id, atlas_coords)
	assert((no_collision_state.get("collision_polygons", []) as Array).is_empty())

	var restored := TerrainTilesetEditServiceScript.with_full_collision(
		TerrainTilesetEditServiceScript.with_tile_definition(no_collision_state, before.get("tile_definition", null) as TileDefinition),
		tile_set.get_tile_size(),
		true
	)
	TerrainTilesetEditServiceScript.apply_cell_states(tile_set, [restored])
	var after := TerrainTilesetEditServiceScript.capture_cell_state(tile_set, source_id, atlas_coords)
	assert(after.get("tile_definition", null) != null)
	assert((after.get("collision_polygons", []) as Array).size() == 1)

	print("source=%d cell=%s restored_polygons=%d" % [source_id, atlas_coords, (after.get("collision_polygons", []) as Array).size()])
	quit()
