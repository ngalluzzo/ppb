extends SceneTree

const BattleMapScene = preload("res://map/battle_map.tscn")
const TerrainPaletteResolverScript = preload("res://addons/map_tools/terrain_palette_resolver.gd")
const TerrainValidationServiceScript = preload("res://addons/map_tools/terrain_validation_service.gd")

func _init() -> void:
	print("--- map validation probe ---")

	var battle_map := BattleMapScene.instantiate() as BattleMap
	root.add_child(battle_map)
	await process_frame

	var terrain := battle_map.get_terrain()
	assert(terrain != null)
	assert(terrain.tile_set != null)

	var entries: Array[TerrainPaletteEntry] = TerrainPaletteResolverScript.resolve(terrain.tile_set)
	var surface_entry := _find_entry(entries, "surface")
	assert(surface_entry != null)

	for team_index in [0, 1]:
		var lane := battle_map.get_spawn_lane(team_index)
		assert(lane != null)
		var floor_world := lane.global_position + Vector2(0.0, 64.0)
		var center_cell := terrain.local_to_map(terrain.to_local(floor_world))
		for x in range(center_cell.x - 8, center_cell.x + 9):
			var paint_cell := Vector2i(x, center_cell.y)
			var variant: Dictionary = surface_entry.cells[absi(x) % surface_entry.cells.size()]
			terrain.set_cell(
				paint_cell,
				int(variant.get("source_id", -1)),
				variant.get("atlas_coords", Vector2i.ZERO),
				int(variant.get("alternative_id", 0))
			)

	terrain.notify_runtime_tile_data_update()
	await process_frame

	var service := TerrainValidationServiceScript.new()
	var issues: Array[TerrainValidationIssue] = service.validate_map(battle_map)
	assert(issues.is_empty())

	print("issues=%d terrain_cells=%d" % [issues.size(), terrain.get_used_cells().size()])
	quit()

func _find_entry(entries: Array[TerrainPaletteEntry], label: String) -> TerrainPaletteEntry:
	for entry in entries:
		if entry.label == label:
			return entry
	return null
