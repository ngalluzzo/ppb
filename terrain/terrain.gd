class_name Terrain
extends TileMapLayer

const TileFragmentScene = preload("res://terrain/impact/tile_fragment.tscn")
const TerrainQueryAdapterScript = preload("res://terrain/terrain_query_adapter.gd")
const TERRAIN_COLLISION_MASK := 1

var _query_adapter: TerrainQueryAdapter

func _ready() -> void:
	_query_adapter = TerrainQueryAdapterScript.new(self)

func get_tile_definition(tile_pos: Vector2i) -> TileDefinition:
	var data = get_cell_tile_data(tile_pos)
	if data == null:
		return null
	return data.get_custom_data("tile_def")

func degrade_tile(tile_pos: Vector2i, impact_position: Vector2) -> void:
	var source_id = get_cell_source_id(tile_pos)
	if source_id == -1:
		return
	var tile_def = get_tile_definition(tile_pos)
	if tile_def == null or not tile_def.destructible:
		return

	_spawn_fragment(tile_pos, impact_position, source_id)

	match tile_def.tile_type:
		"surface":
			_replace_with_random(tile_pos, source_id, 2, 4)
		"mid":
			_replace_with_random(tile_pos, source_id, 5, 7)
		"deep":
			erase_cell(tile_pos)

func get_tile_texture_region(tile_pos: Vector2i) -> Rect2:
	var source_id = get_cell_source_id(tile_pos)
	if source_id == -1:
		return Rect2()
	var atlas_coords = get_cell_atlas_coords(tile_pos)
	var source = tile_set.get_source(source_id) as TileSetAtlasSource
	if source == null:
		return Rect2()
	var tile_size = tile_set.tile_size
	return Rect2(Vector2(atlas_coords) * Vector2(tile_size), Vector2(tile_size))

func find_surface_below(world_pos: Vector2) -> Vector2:
	var tile_pos = local_to_map(to_local(world_pos))
	for y in range(tile_pos.y, tile_pos.y + 100):
		var check = Vector2i(tile_pos.x, y)
		var tile_data = get_cell_tile_data(check)
		if tile_data != null:
			return to_global(map_to_local(Vector2i(tile_pos.x, y - 1)))
	return world_pos

func find_grounded_position(world_pos: Vector2, body_size: Vector2, max_drop: float = 2048.0) -> Vector2:
	if _query_adapter == null:
		_query_adapter = TerrainQueryAdapterScript.new(self)
	return _query_adapter.find_grounded_position(world_pos, body_size, max_drop)

func raycast_ground(world_pos: Vector2, max_drop: float = 2048.0) -> GroundHit:
	if _query_adapter == null:
		_query_adapter = TerrainQueryAdapterScript.new(self)
	return _query_adapter.raycast_ground(world_pos, max_drop)

func _spawn_fragment(tile_pos: Vector2i, impact_position: Vector2, source_id: int) -> void:
	var source = tile_set.get_source(source_id) as TileSetAtlasSource
	if source == null:
		return
	var atlas_coords = get_cell_atlas_coords(tile_pos)
	var tile_size = tile_set.tile_size
	var region = Rect2(Vector2(atlas_coords) * Vector2(tile_size), Vector2(tile_size))
	var world_pos = to_global(map_to_local(tile_pos))
	var direction = (world_pos - impact_position).normalized()
	var fragment = TileFragmentScene.instantiate()
	get_parent().add_child(fragment)
	fragment.setup(source.texture, region, world_pos, direction)

func _replace_with_random(tile_pos: Vector2i, source_id: int, row_min: int, row_max: int) -> void:
	var col = randi_range(0, 7)
	var row = randi_range(row_min, row_max)
	set_cell(tile_pos, source_id, Vector2i(col, row))
