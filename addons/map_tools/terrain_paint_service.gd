@tool
class_name TerrainPaintService
extends RefCounted

var _stroke_before: Dictionary = {}
var _stroke_after: Dictionary = {}

func begin_stroke() -> void:
	_stroke_before.clear()
	_stroke_after.clear()

func apply_brush_at_cell(session: TerrainAuthoringSession, cell: Vector2i) -> void:
	if session == null or session.terrain == null:
		return
	for target_cell in _build_brush_cells(cell, session.brush_state.brush_size):
		if session.brush_state.mode == TerrainBrushState.MODE_ERASE:
			_record_cell_change(session.terrain, target_cell, {"cell": target_cell, "source_id": -1, "atlas_coords": Vector2i.ZERO, "alternative_id": 0})
		else:
			var desired_state := _make_state_for_tile_definition(session, target_cell)
			if not desired_state.is_empty():
				_record_cell_change(session.terrain, target_cell, desired_state)

func apply_rect_operation(session: TerrainAuthoringSession, start_cell: Vector2i, end_cell: Vector2i) -> void:
	if session == null or session.terrain == null:
		return
	var rect := _build_cell_rect(start_cell, end_cell)
	var replace_source := session.brush_state.replace_source_tile_definition
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var cell := Vector2i(x, y)
			match session.brush_state.mode:
				TerrainBrushState.MODE_FILL_RECT:
					var fill_state := _make_state_for_tile_definition(session, cell)
					if not fill_state.is_empty():
						_record_cell_change(session.terrain, cell, fill_state)
				TerrainBrushState.MODE_REPLACE_RECT:
					var existing_def := session.terrain.get_tile_definition(cell)
					if existing_def == null or replace_source == null:
						continue
					if not _matches_tile_definition(existing_def, replace_source):
						continue
					var replace_state := _make_state_for_tile_definition(session, cell)
					if not replace_state.is_empty():
						_record_cell_change(session.terrain, cell, replace_state)
				_:
					pass

func finish_stroke(plugin: EditorPlugin, terrain: Terrain, label: String) -> bool:
	if plugin == null or terrain == null or _stroke_after.is_empty():
		begin_stroke()
		return false
	var before_states := _stroke_before.values()
	var after_states := _stroke_after.values()
	var undo_redo := plugin.get_undo_redo()
	undo_redo.create_action(label)
	undo_redo.add_do_method(self, "_apply_cell_states", terrain, after_states)
	undo_redo.add_undo_method(self, "_apply_cell_states", terrain, before_states)
	undo_redo.commit_action()
	begin_stroke()
	return true

func sample_tile_definition(session: TerrainAuthoringSession, cell: Vector2i) -> TileDefinition:
	if session == null or session.terrain == null:
		return null
	return session.terrain.get_tile_definition(cell)

func _apply_cell_states(terrain: Terrain, states: Array) -> void:
	for state in states:
		var cell: Vector2i = state.get("cell", Vector2i.ZERO)
		var source_id := int(state.get("source_id", -1))
		if source_id < 0:
			terrain.erase_cell(cell)
			continue
		terrain.set_cell(
			cell,
			source_id,
			state.get("atlas_coords", Vector2i.ZERO),
			int(state.get("alternative_id", 0))
		)
	terrain.notify_runtime_tile_data_update()
	terrain.queue_redraw()

func _record_cell_change(terrain: Terrain, cell: Vector2i, desired_state: Dictionary) -> void:
	var key := _cell_key(cell)
	if not _stroke_before.has(key):
		_stroke_before[key] = _capture_cell_state(terrain, cell)
	_stroke_after[key] = desired_state

func _capture_cell_state(terrain: Terrain, cell: Vector2i) -> Dictionary:
	return {
		"cell": cell,
		"source_id": terrain.get_cell_source_id(cell),
		"atlas_coords": terrain.get_cell_atlas_coords(cell),
		"alternative_id": terrain.get_cell_alternative_tile(cell),
	}

func _make_state_for_tile_definition(session: TerrainAuthoringSession, cell: Vector2i) -> Dictionary:
	var entry := session.get_active_palette_entry()
	if entry == null or entry.cells.is_empty():
		return {}
	var cell_options: Array = entry.cells
	var index: int = abs(int(hash("%s:%s" % [cell.x, cell.y]))) % cell_options.size()
	var choice: Dictionary = cell_options[index]
	return {
		"cell": cell,
		"source_id": int(choice.get("source_id", -1)),
		"atlas_coords": choice.get("atlas_coords", Vector2i.ZERO),
		"alternative_id": int(choice.get("alternative_id", 0)),
	}

func _build_brush_cells(center_cell: Vector2i, brush_size: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var radius := maxi(0, brush_size - 1)
	for y in range(center_cell.y - radius, center_cell.y + radius + 1):
		for x in range(center_cell.x - radius, center_cell.x + radius + 1):
			cells.append(Vector2i(x, y))
	return cells

func _build_cell_rect(a: Vector2i, b: Vector2i) -> Rect2i:
	var min_x := mini(a.x, b.x)
	var min_y := mini(a.y, b.y)
	var max_x := maxi(a.x, b.x)
	var max_y := maxi(a.y, b.y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _matches_tile_definition(a: TileDefinition, b: TileDefinition) -> bool:
	if a == null or b == null:
		return a == b
	if a.resource_path != "" and b.resource_path != "":
		return a.resource_path == b.resource_path
	return a == b

func _cell_key(cell: Vector2i) -> String:
	return "%s:%s" % [cell.x, cell.y]
