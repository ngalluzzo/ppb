@tool
class_name TerrainPaletteResolver
extends RefCounted

const TerrainPaletteEntryScript = preload("res://addons/map_tools/terrain_palette_entry.gd")

static func resolve(tile_set: TileSet) -> Array[TerrainPaletteEntry]:
	var grouped: Dictionary = {}
	if tile_set == null:
		return []
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
			var key := _make_group_key(tile_definition)
			if not grouped.has(key):
				var entry: TerrainPaletteEntry = TerrainPaletteEntryScript.new()
				entry.tile_definition = tile_definition
				entry.label = tile_definition.tile_type if tile_definition != null and tile_definition.tile_type != "" else (
					tile_definition.resource_path.get_file().get_basename() if tile_definition != null and tile_definition.resource_path != "" else "Unassigned"
				)
				entry.color = _make_entry_color(tile_definition, key)
				entry.representative_source_id = source_id
				entry.representative_atlas_coords = atlas_coords
				grouped[key] = entry
			var palette_entry := grouped[key] as TerrainPaletteEntry
			palette_entry.cells.append({
				"source_id": source_id,
				"atlas_coords": atlas_coords,
				"alternative_id": 0,
			})
	var entries: Array[TerrainPaletteEntry] = []
	for entry in grouped.values():
		entries.append(entry)
	entries.sort_custom(func(a: TerrainPaletteEntry, b: TerrainPaletteEntry): return a.label.naturalnocasecmp_to(b.label) < 0)
	return entries

static func find_entry_for_tile_definition(entries: Array[TerrainPaletteEntry], tile_definition: TileDefinition) -> TerrainPaletteEntry:
	for entry in entries:
		if entry != null and entry.matches_tile_definition(tile_definition):
			return entry
	return null

static func build_tile_preview(tile_set: TileSet, source_id: int, atlas_coords: Vector2i) -> Texture2D:
	if tile_set == null or not tile_set.has_source(source_id):
		return null
	var source := tile_set.get_source(source_id) as TileSetAtlasSource
	if source == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = source.get_texture()
	atlas.region = source.get_tile_texture_region(atlas_coords)
	return atlas

static func _make_group_key(tile_definition: TileDefinition) -> String:
	if tile_definition == null:
		return "__missing__"
	if tile_definition.resource_path != "":
		return tile_definition.resource_path
	return "instance_%s" % tile_definition.get_instance_id()

static func _make_entry_color(tile_definition: TileDefinition, key: String) -> Color:
	if tile_definition != null:
		match tile_definition.tile_type:
			"surface":
				return Color(0.47, 0.86, 0.46, 0.72)
			"mid":
				return Color(0.90, 0.71, 0.34, 0.72)
			"deep":
				return Color(0.78, 0.45, 0.36, 0.72)
	var hue := fmod(float(abs(hash(key)) % 997) / 997.0, 1.0)
	return Color.from_hsv(hue, 0.55, 0.92, 0.72)

