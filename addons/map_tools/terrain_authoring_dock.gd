@tool
extends VBoxContainer

const CreateMapDockScript = preload("res://addons/map_tools/create_map_dock.gd")
const TerrainPaletteResolverScript = preload("res://addons/map_tools/terrain_palette_resolver.gd")
const TilesetAuthoringPanelScript = preload("res://addons/map_tools/tileset_authoring_panel.gd")

const ToolWorkspaceShellScript = preload("res://ui/system/blocks/tool_workspace_shell.gd")
const InspectorSectionScript = preload("res://ui/system/blocks/inspector_section.gd")
const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const ResourcePathRowScript = preload("res://ui/system/blocks/resource_path_row.gd")
const AppTabsScript = preload("res://ui/system/primitives/app_tabs.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppSelectFieldScript = preload("res://ui/system/primitives/app_select_field.gd")
const AppSpinFieldScript = preload("res://ui/system/primitives/app_spin_field.gd")
const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const TabbedWorkbenchScript = preload("res://ui/composed/shared/tabbed_workbench.gd")
const TerrainContextPanelScript = preload("res://ui/composed/authoring/terrain_context_panel.gd")
const SemanticPalettePanelScript = preload("res://ui/composed/authoring/semantic_palette_panel.gd")
const ValidationWorkbenchScript = preload("res://ui/composed/authoring/validation_workbench.gd")
const OverlayToggleClusterScript = preload("res://ui/system/blocks/overlay_toggle_cluster.gd")
const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const ActionItemViewScript = preload("res://ui/contracts/action_item_view.gd")

var plugin: EditorPlugin
var session: TerrainAuthoringSession

var _shell: Control
var _tabs: TabContainer
var _map_setup_tab: VBoxContainer
var _paint_tab: VBoxContainer
var _validation_tab: VBoxContainer
var _create_map_dock: VBoxContainer
var _tileset_panel: VBoxContainer

var _context_panel: Control
var _brush_mode_select: OptionButton
var _brush_size_spin: SpinBox
var _palette_list: ItemList
var _overlay_semantic_check: CheckBox
var _overlay_destructibility_check: CheckBox
var _overlay_validation_check: CheckBox
var _overlay_spawn_check: CheckBox
var _paint_status_banner: Control
var _palette_panel: Control

var _validation_list: ItemList
var _validation_panel: Control
var _is_refreshing: bool = false

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)
	_build_ui()
	if session != null:
		session.session_changed.connect(_on_session_changed, CONNECT_REFERENCE_COUNTED)
	refresh_from_session()

func set_session(value: TerrainAuthoringSession) -> void:
	session = value
	if is_inside_tree():
		if _tileset_panel != null:
			_tileset_panel.session = session
		if session != null and not session.session_changed.is_connected(_on_session_changed):
			session.session_changed.connect(_on_session_changed, CONNECT_REFERENCE_COUNTED)
		refresh_from_session()

func is_paint_tab_active() -> bool:
	return _tabs != null and _tabs.current_tab == 1

func refresh_from_session() -> void:
	if not is_inside_tree():
		return
	_is_refreshing = true
	_refresh_context_labels()
	_refresh_paint_controls()
	_refresh_validation_list()
	if _tileset_panel != null and _tileset_panel.has_method("refresh_from_session"):
		_tileset_panel.call("refresh_from_session")
	_is_refreshing = false

func _build_ui() -> void:
	_shell = ToolWorkspaceShellScript.new()
	_shell.scope = AppUIScript.Scope.EDITOR
	_shell.set_title_text("Map Tools")
	_shell.set_help_text("Create battle maps, paint semantic terrain directly onto Terrain, author TileSet metadata, and validate map integrity from one workspace.")
	add_child(_shell)

	var workbench = TabbedWorkbenchScript.new()
	workbench.scope = AppUIScript.Scope.EDITOR
	_shell.get_body_root().add_child(workbench)
	_tabs = workbench.get_tabs()

	_build_map_setup_tab()
	_build_paint_tab()
	_build_tileset_tab()
	_build_validation_tab()

func _build_map_setup_tab() -> void:
	_map_setup_tab = VBoxContainer.new()
	_map_setup_tab.name = "Map Setup"
	_tabs.add_child(_map_setup_tab)

	_create_map_dock = CreateMapDockScript.new()
	_create_map_dock.plugin = plugin
	_map_setup_tab.add_child(_create_map_dock)

func _build_paint_tab() -> void:
	_paint_tab = VBoxContainer.new()
	_paint_tab.name = "Terrain Paint"
	_tabs.add_child(_paint_tab)

	_context_panel = TerrainContextPanelScript.new()
	_context_panel.scope = AppUIScript.Scope.EDITOR
	_paint_tab.add_child(_context_panel)

	var brush_section = InspectorSectionScript.new()
	brush_section.scope = AppUIScript.Scope.EDITOR
	brush_section.set_title_text("Brush")
	brush_section.compact = true
	_paint_tab.add_child(brush_section)

	var brush_mode_row = InspectorFieldRowScript.new()
	brush_mode_row.scope = AppUIScript.Scope.EDITOR
	brush_mode_row.set_label_text("Brush Mode")
	brush_section.get_content_root().add_child(brush_mode_row)

	_brush_mode_select = AppSelectFieldScript.new()
	_brush_mode_select.scope = AppUIScript.Scope.EDITOR
	_brush_mode_select.add_item("Paint", 0)
	_brush_mode_select.add_item("Fill Rect", 1)
	_brush_mode_select.add_item("Erase", 2)
	_brush_mode_select.add_item("Replace Rect", 3)
	_brush_mode_select.add_item("Sample", 4)
	_brush_mode_select.item_selected.connect(_on_brush_mode_selected)
	_brush_mode_select.size_flags_horizontal = SIZE_EXPAND_FILL
	brush_mode_row.get_content_root().add_child(_brush_mode_select)

	var brush_size_row = InspectorFieldRowScript.new()
	brush_size_row.scope = AppUIScript.Scope.EDITOR
	brush_size_row.set_label_text("Brush Size")
	brush_section.get_content_root().add_child(brush_size_row)

	_brush_size_spin = AppSpinFieldScript.new()
	_brush_size_spin.scope = AppUIScript.Scope.EDITOR
	_brush_size_spin.min_value = 1
	_brush_size_spin.max_value = 16
	_brush_size_spin.step = 1
	_brush_size_spin.value_changed.connect(_on_brush_size_changed)
	_brush_size_spin.size_flags_horizontal = SIZE_EXPAND_FILL
	brush_size_row.get_content_root().add_child(_brush_size_spin)

	_palette_panel = SemanticPalettePanelScript.new()
	_palette_panel.scope = AppUIScript.Scope.EDITOR
	_palette_panel.set_title_text("Semantic Palette")
	_palette_panel.set_help_text("Choose a TileDefinition semantic and paint it onto the active Terrain layer. The palette is derived from the active TileSet, not hardcoded.")
	_paint_tab.add_child(_palette_panel)

	_palette_list = _palette_panel.get_list()
	_palette_list.item_selected.connect(_on_palette_selected)

	var overlays_section = InspectorSectionScript.new()
	overlays_section.scope = AppUIScript.Scope.EDITOR
	overlays_section.set_title_text("Scene Overlays")
	overlays_section.compact = true
	_paint_tab.add_child(overlays_section)

	var overlay_cluster = OverlayToggleClusterScript.new()
	overlay_cluster.scope = AppUIScript.Scope.EDITOR
	overlays_section.get_content_root().add_child(overlay_cluster)

	_overlay_semantic_check = overlay_cluster.add_toggle("Semantic Tint", _on_overlay_semantic_toggled)
	_overlay_destructibility_check = overlay_cluster.add_toggle("Destructibility Tint", _on_overlay_destructibility_toggled)
	_overlay_validation_check = overlay_cluster.add_toggle("Validation Highlights", _on_overlay_validation_toggled)
	_overlay_spawn_check = overlay_cluster.add_toggle("Spawn Grounding Preview", _on_overlay_spawn_toggled)

	var paint_actions = HBoxContainer.new()
	paint_actions.size_flags_horizontal = SIZE_EXPAND_FILL
	_paint_tab.add_child(paint_actions)
	var refresh_button = AppButtonScript.new()
	refresh_button.scope = AppUIScript.Scope.EDITOR
	refresh_button.variant = AppButtonScript.Variant.SECONDARY
	refresh_button.text = "Refresh Validation"
	refresh_button.pressed.connect(_on_refresh_validation_pressed)
	paint_actions.add_child(refresh_button)

	_paint_status_banner = StatusCalloutScript.new()
	_paint_status_banner.scope = AppUIScript.Scope.EDITOR
	_paint_status_banner.tone = "muted"
	_paint_status_banner.set_text_value("Select a BattleMap or Terrain node to begin painting.")
	_paint_tab.add_child(_paint_status_banner)

func _build_tileset_tab() -> void:
	_tileset_panel = TilesetAuthoringPanelScript.new()
	_tileset_panel.name = "TileSet Authoring"
	_tileset_panel.plugin = plugin
	_tileset_panel.session = session
	_tabs.add_child(_tileset_panel)

func _build_validation_tab() -> void:
	_validation_tab = VBoxContainer.new()
	_validation_tab.name = "Validation"
	_tabs.add_child(_validation_tab)

	_validation_panel = ValidationWorkbenchScript.new()
	_validation_panel.scope = AppUIScript.Scope.EDITOR
	_validation_panel.set_title_text("Map Integrity")
	_validation_panel.set_summary_text("Errors: 0 | Warnings: 0 | Info: 0")
	_validation_panel.set_actions([
		ActionItemViewScript.new(&"refresh", "Refresh", "Refresh validation from the current session.", null, &"secondary"),
		ActionItemViewScript.new(&"focus", "Focus Selected", "Focus the selected validation issue in the editor.", null, &"ghost"),
		ActionItemViewScript.new(&"fix", "Fix Selected", "Apply the direct fix for the selected issue when available.", null, &"ghost"),
	])
	_validation_panel.action_pressed.connect(_on_validation_action_pressed)
	_validation_tab.add_child(_validation_panel)
	_validation_list = _validation_panel.get_list()
	_validation_list.size_flags_vertical = SIZE_EXPAND_FILL
	_validation_list.item_selected.connect(_on_validation_item_selected)

func _refresh_context_labels() -> void:
	var map_name := session.battle_map.name if session != null and session.battle_map != null else "No BattleMap selected"
	var terrain_name := session.terrain.name if session != null and session.terrain != null else "No Terrain selected"
	var tileset_name := session.tile_set.resource_path if session != null and session.tile_set != null and session.tile_set.resource_path != "" else "No TileSet selected"
	_context_panel.set_context(map_name, terrain_name, tileset_name)

func _refresh_paint_controls() -> void:
	if session == null:
		return
	_brush_mode_select.select(_brush_mode_to_index(session.brush_state.mode))
	_brush_size_spin.value = session.brush_state.brush_size
	_overlay_semantic_check.button_pressed = session.overlay_semantic_tint
	_overlay_destructibility_check.button_pressed = session.overlay_destructibility
	_overlay_validation_check.button_pressed = session.overlay_validation
	_overlay_spawn_check.button_pressed = session.overlay_spawn_preview

	_palette_list.clear()
	for entry in session.palette_entries:
		var preview := TerrainPaletteResolverScript.build_tile_preview(
			session.tile_set,
			entry.representative_source_id,
			entry.representative_atlas_coords
		)
		var item_index := _palette_list.add_item(entry.label, preview, true)
		_palette_list.set_item_metadata(item_index, entry.tile_definition)
		_palette_list.set_item_tooltip(item_index, _build_palette_tooltip(entry))
		if entry.matches_tile_definition(session.active_tile_definition):
			_palette_list.select(item_index)

	_palette_panel.set_status_text(_build_paint_status(), "muted")
	_paint_status_banner.tone = "muted"
	_paint_status_banner.set_text_value(_build_paint_status())

func _refresh_validation_list() -> void:
	_validation_list.clear()
	if session == null:
		return
	var counts := {&"error": 0, &"warning": 0, &"info": 0}
	for issue in session.validation_issues:
		var label := issue.to_display_text()
		var item_index := _validation_list.add_item(label)
		_validation_list.set_item_metadata(item_index, issue)
		match issue.severity:
			TerrainValidationIssue.Severity.ERROR:
				counts[&"error"] += 1
				_validation_list.set_item_custom_fg_color(item_index, Color(0.96, 0.36, 0.36))
			TerrainValidationIssue.Severity.WARNING:
				counts[&"warning"] += 1
				_validation_list.set_item_custom_fg_color(item_index, Color(0.98, 0.82, 0.34))
			_:
				counts[&"info"] += 1
	_validation_panel.set_issue_counts(counts[&"error"], counts[&"warning"], counts[&"info"])
	_validation_panel.set_summary_text("Errors: %d | Warnings: %d | Info: %d" % [counts[&"error"], counts[&"warning"], counts[&"info"]])

func _build_paint_status() -> String:
	if session == null or not session.is_ready_for_paint():
		return "Select a BattleMap or Terrain node to begin painting."
	var entry := session.get_active_palette_entry()
	var semantic_name := entry.label if entry != null else "No semantic selected"
	return "Active semantic: %s | Used cells: %d" % [semantic_name, session.terrain.get_used_cells().size()]

func _build_palette_tooltip(entry: TerrainPaletteEntry) -> String:
	var path := entry.tile_definition.resource_path if entry.tile_definition != null else ""
	return "%s\nTileDefinition: %s\nVariants: %d" % [entry.label, path if path != "" else "Inline / unsaved", entry.cells.size()]

func _on_session_changed() -> void:
	refresh_from_session()

func _on_brush_mode_selected(index: int) -> void:
	if _is_refreshing or session == null:
		return
	session.set_brush_mode(_index_to_brush_mode(index))
	plugin.update_overlays()

func _on_brush_size_changed(value: float) -> void:
	if _is_refreshing or session == null:
		return
	session.set_brush_size(int(value))
	plugin.update_overlays()

func _on_palette_selected(index: int) -> void:
	if _is_refreshing or session == null:
		return
	session.set_active_tile_definition(_palette_list.get_item_metadata(index) as TileDefinition)
	plugin.update_overlays()

func _on_overlay_semantic_toggled(enabled: bool) -> void:
	if _is_refreshing:
		return
	session.overlay_semantic_tint = enabled
	if enabled:
		session.overlay_destructibility = false
	_update_overlay_buttons()
	plugin.update_overlays()

func _on_overlay_destructibility_toggled(enabled: bool) -> void:
	if _is_refreshing:
		return
	session.overlay_destructibility = enabled
	if enabled:
		session.overlay_semantic_tint = false
	_update_overlay_buttons()
	plugin.update_overlays()

func _on_overlay_validation_toggled(enabled: bool) -> void:
	if _is_refreshing:
		return
	session.overlay_validation = enabled
	plugin.update_overlays()

func _on_overlay_spawn_toggled(enabled: bool) -> void:
	if _is_refreshing:
		return
	session.overlay_spawn_preview = enabled
	plugin.update_overlays()

func _update_overlay_buttons() -> void:
	_overlay_semantic_check.button_pressed = session.overlay_semantic_tint
	_overlay_destructibility_check.button_pressed = session.overlay_destructibility

func _on_refresh_validation_pressed() -> void:
	if plugin != null:
		plugin.refresh_validation()

func _on_validation_item_selected(index: int) -> void:
	var issue := _validation_list.get_item_metadata(index) as TerrainValidationIssue
	if plugin != null and issue != null:
		plugin.focus_validation_issue(issue)

func _on_focus_issue_pressed() -> void:
	var issue := _get_selected_validation_issue()
	if plugin != null and issue != null:
		plugin.focus_validation_issue(issue)

func _on_fix_issue_pressed() -> void:
	var issue := _get_selected_validation_issue()
	if plugin != null and issue != null:
		plugin.fix_validation_issue(issue)

func _on_validation_action_pressed(id: StringName) -> void:
	match id:
		&"refresh":
			_on_refresh_validation_pressed()
		&"focus":
			_on_focus_issue_pressed()
		&"fix":
			_on_fix_issue_pressed()

func _get_selected_validation_issue() -> TerrainValidationIssue:
	if _validation_list.get_selected_items().is_empty():
		return null
	return _validation_list.get_item_metadata(_validation_list.get_selected_items()[0]) as TerrainValidationIssue

func _brush_mode_to_index(mode: StringName) -> int:
	match mode:
		TerrainBrushState.MODE_FILL_RECT:
			return 1
		TerrainBrushState.MODE_ERASE:
			return 2
		TerrainBrushState.MODE_REPLACE_RECT:
			return 3
		TerrainBrushState.MODE_SAMPLE:
			return 4
		_:
			return 0

func _index_to_brush_mode(index: int) -> StringName:
	match index:
		1:
			return TerrainBrushState.MODE_FILL_RECT
		2:
			return TerrainBrushState.MODE_ERASE
		3:
			return TerrainBrushState.MODE_REPLACE_RECT
		4:
			return TerrainBrushState.MODE_SAMPLE
		_:
			return TerrainBrushState.MODE_PAINT
