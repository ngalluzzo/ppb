@tool
class_name TerrainOverlayController
extends RefCounted

func draw(overlay: Control, session: TerrainAuthoringSession, editor_interface: EditorInterface) -> void:
	if overlay == null or session == null or session.terrain == null or editor_interface == null:
		return
	var viewport_2d := editor_interface.get_editor_viewport_2d()
	if viewport_2d == null:
		return
	var canvas_transform: Transform2D = viewport_2d.get_canvas_transform()
	var tile_size := session.tile_set.get_tile_size() if session.tile_set != null else Vector2i(16, 16)
	if session.overlay_semantic_tint or session.overlay_destructibility:
		for cell in session.terrain.get_used_cells():
			var tile_definition := session.terrain.get_tile_definition(cell)
			var color := _resolve_cell_color(session, tile_definition)
			if color.a <= 0.0:
				continue
			_draw_cell_rect(overlay, canvas_transform, session.terrain, cell, tile_size, color, true, 1.0)
	if session.overlay_validation:
		for issue in session.validation_issues:
			if issue == null:
				continue
			if issue.target_type == &"cell":
				_draw_cell_rect(overlay, canvas_transform, session.terrain, issue.cell, tile_size, Color(1.0, 0.28, 0.28, 0.9), false, 3.0)
			elif issue.target_type == &"spawn_lane" and session.battle_map != null and issue.node_path != NodePath(""):
				var lane := session.battle_map.get_node_or_null(issue.node_path) as SpawnLane2D
				if lane != null:
					var viewport_point := canvas_transform * lane.global_position
					overlay.draw_circle(viewport_point, 8.0, Color(1.0, 0.28, 0.28, 0.9))
	if session.overlay_spawn_preview and session.battle_map != null:
		for team_index in [0, 1]:
			var lane := session.battle_map.get_spawn_lane(team_index)
			if lane == null:
				continue
			var sample_start := lane.global_position + Vector2(0.0, -lane.sample_height * 0.5)
			var hit := session.terrain.raycast_ground(sample_start, lane.sample_height * 2.0)
			var start_view := canvas_transform * sample_start
			var end_view := canvas_transform * (hit.position if hit != null and hit.did_hit else sample_start + Vector2.DOWN * lane.sample_height)
			overlay.draw_line(start_view, end_view, Color(0.99, 0.84, 0.36, 0.95), 2.0)
			overlay.draw_circle(end_view, 4.0, Color(0.99, 0.84, 0.36, 0.95))
	if session.has_hovered_cell:
		_draw_cell_rect(overlay, canvas_transform, session.terrain, session.hovered_cell, tile_size, Color(0.30, 0.70, 0.98, 0.95), false, 2.0)
	if session.brush_state.dragging and session.brush_state.is_rect_mode():
		var rect := Rect2i(
			mini(session.brush_state.drag_start_cell.x, session.brush_state.drag_current_cell.x),
			mini(session.brush_state.drag_start_cell.y, session.brush_state.drag_current_cell.y),
			absi(session.brush_state.drag_current_cell.x - session.brush_state.drag_start_cell.x) + 1,
			absi(session.brush_state.drag_current_cell.y - session.brush_state.drag_start_cell.y) + 1
		)
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				_draw_cell_rect(overlay, canvas_transform, session.terrain, Vector2i(x, y), tile_size, Color(0.30, 0.70, 0.98, 0.20), false, 2.0)
	if session.focused_issue != null and session.focused_issue.target_type == &"cell":
		_draw_cell_rect(overlay, canvas_transform, session.terrain, session.focused_issue.cell, tile_size, Color(1.0, 0.96, 0.35, 0.95), false, 4.0)

func viewport_to_world(editor_interface: EditorInterface, viewport_position: Vector2) -> Vector2:
	var viewport_2d := editor_interface.get_editor_viewport_2d()
	if viewport_2d == null:
		return viewport_position
	return viewport_2d.get_canvas_transform().affine_inverse() * viewport_position

func _draw_cell_rect(
	overlay: Control,
	canvas_transform: Transform2D,
	terrain: Terrain,
	cell: Vector2i,
	tile_size: Vector2i,
	color: Color,
	fill: bool,
	line_width: float
) -> void:
	var world_center := terrain.to_global(terrain.map_to_local(cell))
	var world_rect := Rect2(world_center - Vector2(tile_size) * 0.5, Vector2(tile_size))
	var viewport_rect := Rect2(
		canvas_transform * world_rect.position,
		Vector2(
			(canvas_transform * (world_rect.position + Vector2(world_rect.size.x, 0.0))).x - (canvas_transform * world_rect.position).x,
			(canvas_transform * (world_rect.position + Vector2(0.0, world_rect.size.y))).y - (canvas_transform * world_rect.position).y
		)
	)
	if fill:
		overlay.draw_rect(viewport_rect, color, true)
	overlay.draw_rect(viewport_rect, color, false, line_width)

func _resolve_cell_color(session: TerrainAuthoringSession, tile_definition: TileDefinition) -> Color:
	if session.overlay_destructibility:
		if tile_definition == null:
			return Color(0.85, 0.15, 0.15, 0.18)
		var alpha := clampf(tile_definition.projectile_resistance / 6.0, 0.12, 0.55)
		return Color(0.95, 0.74, 0.32, alpha) if tile_definition.destructible else Color(0.42, 0.68, 0.95, 0.18)
	if not session.overlay_semantic_tint:
		return Color.TRANSPARENT
	var entry := TerrainPaletteResolver.find_entry_for_tile_definition(session.palette_entries, tile_definition)
	return entry.color if entry != null else Color(0.85, 0.15, 0.15, 0.16)
