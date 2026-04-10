extends SceneTree

const TerrainPaletteResolverScript = preload("res://addons/map_tools/terrain_palette_resolver.gd")
const GrassTileSet = preload("res://terrain/tilesets/grass.tres")

func _init() -> void:
	print("--- terrain palette probe ---")

	var entries: Array[TerrainPaletteEntry] = TerrainPaletteResolverScript.resolve(GrassTileSet)
	assert(entries.size() >= 3)

	var labels: Array[String] = []
	for entry in entries:
		labels.append(entry.label)
		assert(entry.tile_definition != null)
		assert(not entry.cells.is_empty())
		assert(entry.representative_source_id >= 0)

	assert(labels.has("surface"))
	assert(labels.has("mid"))
	assert(labels.has("deep"))

	print("entries=%d labels=%s" % [entries.size(), labels])
	quit()
