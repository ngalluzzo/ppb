@tool
extends EditorPlugin

const BattleMapCatalogScript = preload("res://map/battle_map_catalog.gd")
const BattleMapScene = preload("res://map/battle_map.tscn")
const TerrainAuthoringDock = preload("res://addons/map_tools/terrain_authoring_dock.gd")
const TerrainAuthoringSessionScript = preload("res://addons/map_tools/terrain_authoring_session.gd")
const TerrainOverlayControllerScript = preload("res://addons/map_tools/terrain_overlay_controller.gd")
const TerrainPaintServiceScript = preload("res://addons/map_tools/terrain_paint_service.gd")
const TerrainTilesetEditServiceScript = preload("res://addons/map_tools/terrain_tileset_edit_service.gd")
const TerrainValidationServiceScript = preload("res://addons/map_tools/terrain_validation_service.gd")
const MapSizePresetsScript = preload("res://map/map_size_presets.gd")

var _dock: VBoxContainer
var _session: TerrainAuthoringSession
var _overlay_controller: TerrainOverlayController
var _paint_service: TerrainPaintService
var _validation_service: TerrainValidationService
var _last_validated_map: BattleMap
var _last_validated_tileset: TileSet

func _enter_tree() -> void:
	_session = TerrainAuthoringSessionScript.new()
	_overlay_controller = TerrainOverlayControllerScript.new()
	_paint_service = TerrainPaintServiceScript.new()
	_validation_service = TerrainValidationServiceScript.new()

	_dock = TerrainAuthoringDock.new()
	_dock.plugin = self
	_dock.set_session(_session)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)
	set_input_event_forwarding_always_enabled()
	set_force_draw_over_forwarding_enabled()
	set_process(true)

func _exit_tree() -> void:
	if _dock == null:
		return
	remove_control_from_docks(_dock)
	_dock.queue_free()
	_dock = null
	_last_validated_map = null
	_last_validated_tileset = null
	_session = null
	_overlay_controller = null
	_paint_service = null
	_validation_service = null

func _process(_delta: float) -> void:
	if _session == null:
		return
	_session.sync_from_editor(get_editor_interface())
	if _session.battle_map != _last_validated_map or _session.tile_set != _last_validated_tileset:
		refresh_validation()
	update_overlays()

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _session == null or _overlay_controller == null:
		return false
	if event is InputEventMouse and _session.terrain != null:
		var hovered := _event_to_cell(event.position)
		_session.set_hovered_cell(hovered, true)
		update_overlays()

	if not _can_paint_in_scene():
		if event is InputEventMouse and _session != null:
			update_overlays()
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := _event_to_cell(event.position)
		if event.pressed:
			return _handle_left_press(cell)
		return _handle_left_release()

	if event is InputEventMouseMotion and _session.brush_state.dragging:
		var drag_cell := _event_to_cell(event.position)
		if _session.brush_state.is_paint_stroke_mode():
			_paint_service.apply_brush_at_cell(_session, drag_cell)
		else:
			_session.brush_state.drag_current_cell = drag_cell
		update_overlays()
		return true

	return false

func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if _overlay_controller == null or _session == null:
		return
	_overlay_controller.draw(overlay, _session, get_editor_interface())

func create_standard_map(display_name: String, slug: String, preset_index: int) -> Dictionary:
	var directory_path := "res://roster/maps/%s" % slug
	var scene_path := "%s/%s.tscn" % [directory_path, slug]
	var catalog_path := "%s/map_catalog_%s.tres" % [directory_path, slug]

	var make_dir_result := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory_path))
	if make_dir_result != OK:
		return {"ok": false, "message": "Could not create directory: %s" % directory_path}

	if ResourceLoader.exists(scene_path) or ResourceLoader.exists(catalog_path):
		return {"ok": false, "message": "Map files already exist for %s." % slug}

	var map_scene := BattleMapScene as PackedScene
	if map_scene == null:
		return {"ok": false, "message": "Base BattleMap scene is missing."}

	var map_root := map_scene.instantiate() as BattleMap
	if map_root == null:
		return {"ok": false, "message": "Base BattleMap scene could not be instantiated."}

	map_root.name = "BattleMap"
	_apply_preset_to_map_root(map_root, preset_index)

	var packed_map := PackedScene.new()
	var pack_result := packed_map.pack(map_root)
	if pack_result != OK:
		map_root.free()
		return {"ok": false, "message": "Could not pack generated map scene."}

	var save_scene_result := ResourceSaver.save(packed_map, scene_path)
	map_root.free()
	if save_scene_result != OK:
		return {"ok": false, "message": "Could not save scene to %s" % scene_path}

	var generated_scene := load(scene_path) as PackedScene
	if generated_scene == null:
		return {"ok": false, "message": "Could not reload generated scene at %s" % scene_path}

	var map_catalog := BattleMapCatalogScript.new()
	map_catalog.display_name = display_name
	map_catalog.map_scene = generated_scene

	var save_catalog_result := ResourceSaver.save(map_catalog, catalog_path)
	if save_catalog_result != OK:
		return {"ok": false, "message": "Could not save map catalog to %s" % catalog_path}

	var filesystem := get_editor_interface().get_resource_filesystem()
	if filesystem != null:
		filesystem.scan()

	get_editor_interface().open_scene_from_path(scene_path)
	return {
		"ok": true,
		"message": "Created %s at %s" % [display_name, scene_path]
	}

func _apply_preset_to_map_root(map_root: BattleMap, preset_index: int) -> void:
	var world_bounds := MapSizePresetsScript.get_world_bounds(preset_index)
	var camera_bounds := MapSizePresetsScript.get_camera_bounds(preset_index)
	var spawn_positions := MapSizePresetsScript.get_spawn_positions(preset_index)
	var lane_width := MapSizePresetsScript.get_lane_width(preset_index)
	var sample_height := MapSizePresetsScript.get_sample_height(preset_index)

	map_root.world_bounds = world_bounds
	map_root.camera_bounds = camera_bounds
	_apply_spawn_lane(map_root.get_node("SpawnLanes/TeamA") as SpawnLane2D, spawn_positions[0], 0, 1, lane_width, sample_height)
	_apply_spawn_lane(map_root.get_node("SpawnLanes/TeamB") as SpawnLane2D, spawn_positions[1], 1, -1, lane_width, sample_height)
	map_root.notify_authoring_changed()

func _apply_spawn_lane(
	lane: SpawnLane2D,
	position: Vector2,
	team_index: int,
	facing_direction: int,
	lane_width: float,
	sample_height: float
) -> void:
	if lane == null:
		return

	lane.position = position
	lane.team_index = team_index
	lane.facing_direction = facing_direction
	lane.lane_width = lane_width
	lane.sample_height = sample_height

func refresh_validation() -> void:
	if _session == null:
		return
	_last_validated_map = _session.battle_map
	_last_validated_tileset = _session.tile_set
	var issues: Array[TerrainValidationIssue] = []
	if _session.tile_set != null:
		for issue in _validation_service.validate_tileset(_session.tile_set):
			issues.append(issue)
	if _session.battle_map != null:
		for issue in _validation_service.validate_map(_session.battle_map):
			issues.append(issue)
	_session.set_validation_issues(issues)
	update_overlays()

func apply_tileset_semantic_assignment(tile_definition: TileDefinition, source_id: int, cells: Array[Vector2i]) -> void:
	if _session == null or _session.tile_set == null or source_id < 0 or cells.is_empty():
		return
	var before_states: Array[Dictionary] = []
	var after_states: Array[Dictionary] = []
	for atlas_coords in cells:
		var before := TerrainTilesetEditServiceScript.capture_cell_state(_session.tile_set, source_id, atlas_coords)
		if before.is_empty():
			continue
		before_states.append(before)
		after_states.append(TerrainTilesetEditServiceScript.with_tile_definition(before, tile_definition))
	_commit_tileset_edit("Assign Tile Semantics", before_states, after_states)

func apply_tileset_collision(enabled: bool, source_id: int, cells: Array[Vector2i], only_if_missing: bool = false) -> void:
	if _session == null or _session.tile_set == null or source_id < 0 or cells.is_empty():
		return
	var before_states: Array[Dictionary] = []
	var after_states: Array[Dictionary] = []
	var tile_size := _session.tile_set.get_tile_size()
	for atlas_coords in cells:
		var before := TerrainTilesetEditServiceScript.capture_cell_state(_session.tile_set, source_id, atlas_coords)
		if before.is_empty():
			continue
		if only_if_missing and not before.get("collision_polygons", []).is_empty():
			continue
		before_states.append(before)
		after_states.append(TerrainTilesetEditServiceScript.with_full_collision(before, tile_size, enabled))
	_commit_tileset_edit("Update Tile Collision", before_states, after_states)

func focus_validation_issue(issue: TerrainValidationIssue) -> void:
	if issue == null or _session == null:
		return
	_session.focused_issue = issue
	var selection := get_editor_interface().get_selection()
	if issue.node_path != NodePath("") and _session.battle_map != null:
		var node := _session.battle_map.get_node_or_null(issue.node_path)
		if node != null and selection != null:
			selection.clear()
			selection.add_node(node)
			get_editor_interface().edit_node(node)
	else:
		if _session.terrain != null and selection != null:
			selection.clear()
			selection.add_node(_session.terrain)
			get_editor_interface().edit_node(_session.terrain)
	update_overlays()

func fix_validation_issue(issue: TerrainValidationIssue) -> void:
	if issue == null:
		return
	if issue.kind == &"missing_collision" and issue.source_id >= 0:
		apply_tileset_collision(true, issue.source_id, [issue.atlas_coords], true)
		return
	focus_validation_issue(issue)

func _handle_left_press(cell: Vector2i) -> bool:
	match _session.brush_state.mode:
		TerrainBrushState.MODE_SAMPLE:
			var sampled := _paint_service.sample_tile_definition(_session, cell)
			if sampled != null:
				_session.set_active_tile_definition(sampled)
			update_overlays()
			return true
		TerrainBrushState.MODE_PAINT, TerrainBrushState.MODE_ERASE:
			_paint_service.begin_stroke()
			_session.brush_state.dragging = true
			_paint_service.apply_brush_at_cell(_session, cell)
			update_overlays()
			return true
		TerrainBrushState.MODE_FILL_RECT, TerrainBrushState.MODE_REPLACE_RECT:
			_session.brush_state.dragging = true
			_session.brush_state.drag_start_cell = cell
			_session.brush_state.drag_current_cell = cell
			if _session.brush_state.mode == TerrainBrushState.MODE_REPLACE_RECT:
				_session.brush_state.replace_source_tile_definition = _paint_service.sample_tile_definition(_session, cell)
			update_overlays()
			return true
	return false

func _handle_left_release() -> bool:
	if _session == null or not _session.brush_state.dragging:
		return false
	var handled := false
	if _session.brush_state.is_paint_stroke_mode():
		handled = _paint_service.finish_stroke(self, _session.terrain, _stroke_label_for_mode())
	else:
		_paint_service.begin_stroke()
		_paint_service.apply_rect_operation(
			_session,
			_session.brush_state.drag_start_cell,
			_session.brush_state.drag_current_cell
		)
		handled = _paint_service.finish_stroke(self, _session.terrain, _stroke_label_for_mode())
	_session.brush_state.dragging = false
	_session.brush_state.replace_source_tile_definition = null
	update_overlays()
	return handled

func _stroke_label_for_mode() -> String:
	match _session.brush_state.mode:
		TerrainBrushState.MODE_ERASE:
			return "Erase Terrain Tiles"
		TerrainBrushState.MODE_FILL_RECT:
			return "Fill Terrain Rectangle"
		TerrainBrushState.MODE_REPLACE_RECT:
			return "Replace Terrain Rectangle"
		_:
			return "Paint Terrain Tiles"

func _can_paint_in_scene() -> bool:
	return (
		_dock != null
		and _dock.has_method("is_paint_tab_active")
		and _dock.call("is_paint_tab_active")
		and _session != null
		and _session.is_ready_for_paint()
	)

func _event_to_cell(viewport_position: Vector2) -> Vector2i:
	var world := _overlay_controller.viewport_to_world(get_editor_interface(), viewport_position)
	return _session.terrain.local_to_map(_session.terrain.to_local(world))

func _commit_tileset_edit(label: String, before_states: Array[Dictionary], after_states: Array[Dictionary]) -> void:
	if before_states.is_empty() or after_states.is_empty() or _session == null or _session.tile_set == null:
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action(label)
	undo_redo.add_do_method(self, "_apply_tileset_states", _session.tile_set, after_states)
	undo_redo.add_do_method(self, "_refresh_after_tileset_edit")
	undo_redo.add_undo_method(self, "_apply_tileset_states", _session.tile_set, before_states)
	undo_redo.add_undo_method(self, "_refresh_after_tileset_edit")
	undo_redo.commit_action()

func _apply_tileset_states(tile_set: TileSet, states: Array[Dictionary]) -> void:
	TerrainTilesetEditServiceScript.apply_cell_states(tile_set, states)
	if _session != null and _session.terrain != null:
		_session.terrain.notify_runtime_tile_data_update()
		_session.terrain.queue_redraw()

func _refresh_after_tileset_edit() -> void:
	if _session == null:
		return
	_session.rebuild_palette()
	refresh_validation()
