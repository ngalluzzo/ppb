@tool
class_name TerrainContextPanel
extends VBoxContainer

const LinkedResourceSectionScript = preload("res://ui/system/blocks/linked_resource_section.gd")
const ResourcePathRowScript = preload("res://ui/system/blocks/resource_path_row.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _section: LinkedResourceSection
var _map_row: ResourcePathRow
var _terrain_row: ResourcePathRow
var _tileset_row: ResourcePathRow

func _ready() -> void:
	if _section != null:
		return
	_section = LinkedResourceSectionScript.new()
	_section.scope = scope
	_section.set_title_text("Terrain Context")
	add_child(_section)
	_map_row = ResourcePathRowScript.new()
	_map_row.scope = scope
	_map_row.set_label_text("BattleMap")
	_section.get_content_root().add_child(_map_row)
	_terrain_row = ResourcePathRowScript.new()
	_terrain_row.scope = scope
	_terrain_row.set_label_text("Terrain")
	_section.get_content_root().add_child(_terrain_row)
	_tileset_row = ResourcePathRowScript.new()
	_tileset_row.scope = scope
	_tileset_row.set_label_text("TileSet")
	_section.get_content_root().add_child(_tileset_row)

func set_context(map_name: String, terrain_name: String, tileset_name: String) -> void:
	_ready()
	_map_row.set_value_text(map_name)
	_terrain_row.set_value_text(terrain_name)
	_tileset_row.set_value_text(tileset_name)

