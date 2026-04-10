@tool
extends VBoxContainer

const TerrainPaletteResolverScript = preload("res://addons/map_tools/terrain_palette_resolver.gd")

const InspectorSectionScript = preload("res://ui/system/blocks/inspector_section.gd")
const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const ResourcePickerRowScript = preload("res://ui/system/blocks/resource_picker_row.gd")
const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const TileSetSelectionWorkbenchScript = preload("res://ui/composed/authoring/tile_set_selection_workbench.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppSelectFieldScript = preload("res://ui/system/primitives/app_select_field.gd")
const ActionItemViewScript = preload("res://ui/contracts/action_item_view.gd")

var plugin: EditorPlugin
var session: TerrainAuthoringSession

var _source_select: OptionButton
var _tile_definition_row: Control
var _tiles_list: ItemList
var _status_banner: Control
var _tiles_workbench: Control
var _is_refreshing: bool = false

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)

	var section = InspectorSectionScript.new()
	section.scope = AppUIScript.Scope.EDITOR
	section.set_title_text("TileSet Authoring")
	add_child(section)

	var help = AppLabelScript.new()
	help.scope = AppUIScript.Scope.EDITOR
	help.role = "body"
	help.text_role = "muted"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = "Inspect atlas cells, assign tile semantics, and batch-create default full-tile collision."
	section.get_content_root().add_child(help)

	var source_row = InspectorFieldRowScript.new()
	source_row.scope = AppUIScript.Scope.EDITOR
	source_row.set_label_text("Tile Source")
	section.get_content_root().add_child(source_row)
	_source_select = AppSelectFieldScript.new()
	_source_select.scope = AppUIScript.Scope.EDITOR
	_source_select.size_flags_horizontal = SIZE_EXPAND_FILL
	_source_select.item_selected.connect(_on_source_selected)
	source_row.get_content_root().add_child(_source_select)

	_tile_definition_row = ResourcePickerRowScript.new()
	_tile_definition_row.scope = AppUIScript.Scope.EDITOR
	_tile_definition_row.set_label_text("Assign TileDefinition")
	_tile_definition_row.set_base_type("TileDefinition")
	_tile_definition_row.resource_changed.connect(_on_tile_definition_changed)
	section.get_content_root().add_child(_tile_definition_row)

	_tiles_workbench = TileSetSelectionWorkbenchScript.new()
	_tiles_workbench.scope = AppUIScript.Scope.EDITOR
	_tiles_workbench.set_title_text("Atlas Cells")
	_tiles_workbench.set_help_text("Select one or more cells to edit semantics and collision in place on the active TileSet source.")
	_tiles_workbench.action_pressed.connect(_on_workbench_action_pressed)
	_tiles_workbench.set_actions([
		ActionItemViewScript.new(&"assign", "Assign Semantic", "Assign the selected TileDefinition to the current selection.", null, &"primary"),
		ActionItemViewScript.new(&"clear_semantic", "Clear Semantic", "Clear the tile_def custom data assignment.", null, &"ghost"),
		ActionItemViewScript.new(&"apply_collision", "Apply Collision", "Apply default full-tile collision to the selection.", null, &"secondary"),
		ActionItemViewScript.new(&"clear_collision", "Clear Collision", "Clear collision on the selected atlas cells.", null, &"ghost"),
		ActionItemViewScript.new(&"fix_collision", "Fix Missing Collision", "Apply collision only where it is missing.", null, &"secondary"),
		ActionItemViewScript.new(&"refresh", "Refresh Cells", "Reload atlas cell previews from the active TileSet.", null, &"ghost"),
	])
	section.get_content_root().add_child(_tiles_workbench)

	_tiles_list = _tiles_workbench.get_list()
	_tiles_list.item_selected.connect(_on_selection_changed)
	_tiles_list.multi_selected.connect(_on_multi_selection_changed)

	_status_banner = StatusCalloutScript.new()
	_status_banner.scope = AppUIScript.Scope.EDITOR
	_status_banner.tone = "muted"
	_status_banner.set_text_value("Select a Terrain node with a TileSet to inspect atlas cells.")
	section.get_content_root().add_child(_status_banner)

	refresh_from_session()

func refresh_from_session() -> void:
	_is_refreshing = true
	_rebuild_sources()
	_rebuild_tiles()
	_refresh_selection_state()
	_is_refreshing = false

func _rebuild_sources() -> void:
	var previous_source := session.active_source_id if session != null else -1
	_source_select.clear()
	if session == null or session.tile_set == null:
		_source_select.disabled = true
		return
	_source_select.disabled = false
	for source_index in session.tile_set.get_source_count():
		var source_id := session.tile_set.get_source_id(source_index)
		_source_select.add_item("Source %d" % source_id, source_id)
		if source_id == previous_source:
			_source_select.select(_source_select.item_count - 1)
	if _source_select.item_count > 0 and _source_select.selected < 0:
		_source_select.select(0)
		session.set_active_source_id(_source_select.get_selected_id())

func _rebuild_tiles() -> void:
	_tiles_list.clear()
	if session == null or session.tile_set == null or session.active_source_id < 0:
		_set_status("Select a Terrain node with a TileSet to inspect atlas cells.", "muted")
		return
	var source := session.tile_set.get_source(session.active_source_id) as TileSetAtlasSource
	if source == null:
		_set_status("The active TileSet source is not an atlas source.", "warning")
		return
	for tile_index in source.get_tiles_count():
		var atlas_coords: Vector2i = source.get_tile_id(tile_index)
		var tile_data := source.get_tile_data(atlas_coords, 0)
		if tile_data == null:
			continue
		var tile_definition := tile_data.get_custom_data("tile_def") as TileDefinition
		var preview := TerrainPaletteResolverScript.build_tile_preview(session.tile_set, session.active_source_id, atlas_coords)
		var label := "%s\n%s" % [_format_coords(atlas_coords), _get_tile_definition_label(tile_definition)]
		var item_index := _tiles_list.add_item(label, preview, true)
		_tiles_list.set_item_metadata(item_index, atlas_coords)
		_tiles_list.set_item_tooltip(item_index, _build_tooltip(tile_definition, tile_data, atlas_coords))
	_restore_selection()
	_set_status("Loaded %d atlas cells from source %d." % [_tiles_list.item_count, session.active_source_id], "muted")

func _restore_selection() -> void:
	if session == null or session.selected_tileset_cells.is_empty():
		return
	for item_index in _tiles_list.item_count:
		var atlas_coords: Vector2i = _tiles_list.get_item_metadata(item_index)
		for selected in session.selected_tileset_cells:
			if selected == atlas_coords:
				_tiles_list.select(item_index, false)
				break

func _refresh_selection_state() -> void:
	var selected := _get_selected_cells()
	if session != null and not _is_refreshing:
		session.set_selected_tileset_cells(selected)
	var selected_count := selected.size()
	_tiles_workbench.set_selection_status("%d atlas cell%s selected." % [selected_count, "" if selected_count == 1 else "s"])

	var active_definition := _tile_definition_row.get_edited_resource() as TileDefinition
	if active_definition == null and session != null:
		active_definition = session.active_tile_definition
		if active_definition != null:
			_tile_definition_row.set_edited_resource(active_definition)

func _get_selected_cells() -> Array[Vector2i]:
	var selected: Array[Vector2i] = []
	for item_index in _tiles_list.get_selected_items():
		selected.append(_tiles_list.get_item_metadata(item_index) as Vector2i)
	return selected

func _on_source_selected(_index: int) -> void:
	if _is_refreshing or session == null:
		return
	session.set_active_source_id(_source_select.get_selected_id())
	refresh_from_session()

func _on_tile_definition_changed(resource: Resource) -> void:
	if _is_refreshing or session == null:
		return
	session.set_active_tile_definition(resource as TileDefinition)
	_set_status("Assignment target set to %s." % _get_tile_definition_label(resource as TileDefinition), "info")

func _on_selection_changed(_index: int) -> void:
	if _is_refreshing:
		return
	_refresh_selection_state()

func _on_multi_selection_changed(_index: int, _selected: bool) -> void:
	if _is_refreshing:
		return
	_refresh_selection_state()

func _on_assign_pressed() -> void:
	if plugin == null or session == null:
		return
	var tile_definition := _tile_definition_row.get_edited_resource() as TileDefinition
	if tile_definition == null:
		_set_status("Pick a TileDefinition resource before assigning semantics.", "warning")
		return
	var cells := _get_selected_cells()
	if cells.is_empty():
		_set_status("Select one or more atlas cells first.", "warning")
		return
	plugin.apply_tileset_semantic_assignment(tile_definition, session.active_source_id, cells)
	_set_status("Assigned %s to %d atlas cell%s." % [
		_get_tile_definition_label(tile_definition),
		cells.size(),
		"" if cells.size() == 1 else "s"
	], "success")

func _on_clear_semantic_pressed() -> void:
	if plugin == null or session == null:
		return
	var cells := _get_selected_cells()
	if cells.is_empty():
		_set_status("Select one or more atlas cells first.", "warning")
		return
	plugin.apply_tileset_semantic_assignment(null, session.active_source_id, cells)
	_set_status("Cleared tile_def metadata on %d atlas cell%s." % [cells.size(), "" if cells.size() == 1 else "s"], "success")

func _on_apply_collision_pressed() -> void:
	_apply_collision(false, true)

func _on_clear_collision_pressed() -> void:
	_apply_collision(false, false)

func _on_fix_missing_collision_pressed() -> void:
	_apply_collision(true, true)

func _apply_collision(only_if_missing: bool, enabled: bool) -> void:
	if plugin == null or session == null:
		return
	var cells := _get_selected_cells()
	if cells.is_empty():
		_set_status("Select one or more atlas cells first.", "warning")
		return
	plugin.apply_tileset_collision(enabled, session.active_source_id, cells, only_if_missing)
	if only_if_missing:
		_set_status("Applied collision to atlas cells missing it.", "success")
	else:
		_set_status("%s collision on %d atlas cell%s." % [
			"Applied" if enabled else "Cleared",
			cells.size(),
			"" if cells.size() == 1 else "s"
		], "success")

func _on_refresh_pressed() -> void:
	refresh_from_session()

func _on_workbench_action_pressed(id: StringName) -> void:
	match id:
		&"assign":
			_on_assign_pressed()
		&"clear_semantic":
			_on_clear_semantic_pressed()
		&"apply_collision":
			_on_apply_collision_pressed()
		&"clear_collision":
			_on_clear_collision_pressed()
		&"fix_collision":
			_on_fix_missing_collision_pressed()
		&"refresh":
			_on_refresh_pressed()

func _add_action_button(parent: Control, text: String, variant: int, callback: Callable) -> void:
	var button = AppButtonScript.new()
	button.scope = AppUIScript.Scope.EDITOR
	button.variant = variant
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)

func _set_status(text: String, tone: String) -> void:
	_status_banner.tone = tone
	_status_banner.set_text_value(text)

func _get_tile_definition_label(tile_definition: TileDefinition) -> String:
	if tile_definition == null:
		return "None"
	if tile_definition.resource_path != "":
		return tile_definition.resource_path.get_file().get_basename()
	return tile_definition.tile_type if tile_definition.tile_type != "" else tile_definition.resource_name

func _build_tooltip(tile_definition: TileDefinition, tile_data: TileData, atlas_coords: Vector2i) -> String:
	return "%s\nSemantic: %s\nCollision polygons: %d" % [
		_format_coords(atlas_coords),
		_get_tile_definition_label(tile_definition),
		tile_data.get_collision_polygons_count(0)
	]

func _format_coords(coords: Vector2i) -> String:
	return "(%d, %d)" % [coords.x, coords.y]
