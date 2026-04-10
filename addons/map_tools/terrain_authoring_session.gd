@tool
class_name TerrainAuthoringSession
extends RefCounted

const TerrainPaletteResolverScript = preload("res://addons/map_tools/terrain_palette_resolver.gd")
const TerrainBrushStateScript = preload("res://addons/map_tools/terrain_brush_state.gd")

signal session_changed()

var battle_map: BattleMap
var terrain: Terrain
var tile_set: TileSet
var active_source_id: int = -1
var palette_entries: Array[TerrainPaletteEntry] = []
var active_tile_definition: TileDefinition
var brush_state: TerrainBrushState = TerrainBrushStateScript.new()
var overlay_semantic_tint: bool = true
var overlay_validation: bool = true
var overlay_spawn_preview: bool = true
var overlay_destructibility: bool = false
var validation_issues: Array[TerrainValidationIssue] = []
var hovered_cell: Vector2i = Vector2i.ZERO
var has_hovered_cell: bool = false
var focused_issue: TerrainValidationIssue
var selected_tileset_cells: Array[Vector2i] = []

func sync_from_editor(editor_interface: EditorInterface) -> void:
	var selected_map := _find_selected_map(editor_interface)
	var selected_terrain := _find_selected_terrain(editor_interface, selected_map)
	var selected_tile_set := selected_terrain.tile_set if selected_terrain != null else null
	var changed := selected_map != battle_map or selected_terrain != terrain or selected_tile_set != tile_set
	battle_map = selected_map
	terrain = selected_terrain
	tile_set = selected_tile_set
	if tile_set == null:
		active_source_id = -1
		palette_entries = []
		active_tile_definition = null
		selected_tileset_cells.clear()
	else:
		if active_source_id == -1 or not tile_set.has_source(active_source_id):
			active_source_id = _find_first_source_id(tile_set)
		rebuild_palette()
	if changed:
		session_changed.emit()

func rebuild_palette() -> void:
	palette_entries = TerrainPaletteResolverScript.resolve(tile_set)
	if active_tile_definition == null and not palette_entries.is_empty():
		active_tile_definition = palette_entries[0].tile_definition
	elif active_tile_definition != null and TerrainPaletteResolverScript.find_entry_for_tile_definition(palette_entries, active_tile_definition) == null:
		active_tile_definition = palette_entries[0].tile_definition if not palette_entries.is_empty() else null
	session_changed.emit()

func set_active_tile_definition(tile_definition: TileDefinition) -> void:
	active_tile_definition = tile_definition
	session_changed.emit()

func set_active_source_id(source_id: int) -> void:
	active_source_id = source_id
	selected_tileset_cells.clear()
	session_changed.emit()

func set_brush_mode(mode: StringName) -> void:
	brush_state.mode = mode
	session_changed.emit()

func set_brush_size(size: int) -> void:
	brush_state.brush_size = maxi(1, size)
	session_changed.emit()

func set_validation_issues(issues: Array[TerrainValidationIssue]) -> void:
	validation_issues = issues
	session_changed.emit()

func set_selected_tileset_cells(cells: Array[Vector2i]) -> void:
	if _vector2i_arrays_equal(selected_tileset_cells, cells):
		return
	selected_tileset_cells = cells.duplicate()
	session_changed.emit()

func set_hovered_cell(cell: Vector2i, has_cell: bool = true) -> void:
	hovered_cell = cell
	has_hovered_cell = has_cell

func get_active_palette_entry() -> TerrainPaletteEntry:
	return TerrainPaletteResolverScript.find_entry_for_tile_definition(palette_entries, active_tile_definition)

func is_ready_for_paint() -> bool:
	return terrain != null and tile_set != null

func clear_focus() -> void:
	focused_issue = null

func _find_selected_map(editor_interface: EditorInterface) -> BattleMap:
	if editor_interface == null:
		return null
	var selection := editor_interface.get_selection()
	if selection != null:
		for node in selection.get_selected_nodes():
			if node is BattleMap:
				return node as BattleMap
			if node is Node:
				var parent := node.get_parent()
				while parent != null:
					if parent is BattleMap:
						return parent as BattleMap
					parent = parent.get_parent()
	var root := editor_interface.get_edited_scene_root()
	return root as BattleMap if root is BattleMap else null

func _find_selected_terrain(editor_interface: EditorInterface, selected_map: BattleMap) -> Terrain:
	if editor_interface == null:
		return null
	var selection := editor_interface.get_selection()
	if selection != null:
		for node in selection.get_selected_nodes():
			if node is Terrain:
				return node as Terrain
	if selected_map != null:
		return selected_map.get_terrain()
	return null

func _find_first_source_id(p_tile_set: TileSet) -> int:
	if p_tile_set == null or p_tile_set.get_source_count() <= 0:
		return -1
	return p_tile_set.get_source_id(0)

func _vector2i_arrays_equal(a: Array[Vector2i], b: Array[Vector2i]) -> bool:
	if a.size() != b.size():
		return false
	for index in a.size():
		if a[index] != b[index]:
			return false
	return true
