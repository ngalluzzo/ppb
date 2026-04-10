@tool
class_name TerrainPaletteEntry
extends RefCounted

var tile_definition: TileDefinition
var label: String = ""
var color: Color = Color.WHITE
var cells: Array[Dictionary] = []
var representative_source_id: int = -1
var representative_atlas_coords: Vector2i = Vector2i.ZERO

func matches_tile_definition(other: TileDefinition) -> bool:
	if tile_definition == null or other == null:
		return tile_definition == other
	if tile_definition.resource_path != "" and other.resource_path != "":
		return tile_definition.resource_path == other.resource_path
	return tile_definition == other

