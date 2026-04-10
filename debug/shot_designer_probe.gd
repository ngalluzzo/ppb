extends SceneTree

const ShotPreviewSessionScript = preload("res://addons/shot_designer/shot_preview_session.gd")
const ShotPreviewViewportScript = preload("res://addons/shot_designer/shot_preview_viewport.gd")

func _init() -> void:
	print("--- shot designer probe ---")
	var session := ShotPreviewSessionScript.new()
	var mobile_def := load("res://roster/mobiles/ironclad/ironclad_mobile_definition.tres") as MobileDefinition
	session.open_mobile_slot(mobile_def, &"shot_1")
	session.overrides.shot_pattern.unit_count = 4
	session.mark_dirty(&"shot_pattern")
	session.overrides.power = 72.0
	session.overrides.angle = 48.0

	var viewport := ShotPreviewViewportScript.new()
	root.add_child(viewport)
	await process_frame
	viewport.set_session(session)

	for _frame in 45:
		await process_frame

	var battle_system = viewport.get("_battle_system") as BattleSystem
	var actor = viewport.get("_actor_node")
	var floor_body := battle_system.get_world_root().get_node_or_null("__PreviewFloor") if battle_system != null else null
	var wall_body := battle_system.get_world_root().get_node_or_null("__PreviewWall") if battle_system != null else null
	var cannon: Cannon = null
	if actor is Mobile:
		cannon = (actor as Mobile).cannon
	elif actor is Cannon:
		cannon = actor as Cannon
	print(
		"actor=%s cannon=%s muzzle=%s floor=%s wall=%s" % [
			actor.global_position if actor != null else Vector2.ZERO,
			cannon.global_position if cannon != null else Vector2.ZERO,
			cannon.get_muzzle_position() if cannon != null else Vector2.ZERO,
			floor_body.global_position if floor_body != null else Vector2.ZERO,
			wall_body.global_position if wall_body != null else Vector2.ZERO,
		]
	)

	var snapshot := viewport.get_capture_snapshot()
	var trajectories: Array = snapshot.get("trajectories", [])
	var endpoints: Array = snapshot.get("endpoints", [])
	var point_counts := trajectories.map(func(track: Dictionary): return (track.get("points", []) as Array).size())
	var labels := endpoints.map(func(endpoint: Dictionary): return str(endpoint.get("impact_label", "")))
	var first_points := []
	for track in trajectories:
		var points: Array = track.get("points", [])
		if points.is_empty():
			continue
		first_points.append({
			"start": points[0],
			"end": points[-1],
		})
	print(
		"projectiles=%d active=%d spread=%.1f airtime=%.2f points=%s labels=%s spans=%s" % [
			int(snapshot.get("projectile_count", 0)),
			int(snapshot.get("active_projectiles", 0)),
			float(snapshot.get("spread_width", 0.0)),
			float(snapshot.get("max_airtime_seconds", 0.0)),
			point_counts,
			labels,
			first_points
		]
	)
	assert(int(snapshot.get("projectile_count", 0)) >= 1)
	quit()
