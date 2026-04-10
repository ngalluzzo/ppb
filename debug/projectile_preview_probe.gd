extends SceneTree

const ShotExecutionServiceScript = preload("res://weapon/shot/shot_execution_service.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var pattern: ShotPattern = load("res://weapon/shot/shot_1_default.tres")
	var weather_config = load("res://roster/weather/match_weather_default.tres")

	var battle_system := BattleSystem.new()
	root.add_child(battle_system)
	await process_frame
	battle_system.begin_editor_preview("Projectile Probe", weather_config, 13)

	var service: ShotExecutionService = ShotExecutionServiceScript.new()
	battle_system.add_child(service)

	var event := ShotEvent.new()
	event.shot_id = 303
	event.shooter_id = "probe"
	event.shot_slot = &"shot_1"
	event.muzzle_position = Vector2(140.0, 220.0)
	event.aim_direction = Vector2(1.0, -0.8).normalized()
	event.resolved_power = 26.0
	event.base_velocity = event.aim_direction * (26.0 * pattern.arc_config.power_scale)
	event.created_frame = 0
	event.projectile_count = 1
	event.stagger_delay = 0.0
	event.unit_spacing = pattern.unit_spacing
	event.max_range = pattern.max_range
	event.gravity = pattern.arc_config.gravity
	event.power_scale = pattern.arc_config.power_scale
	event.rng_seed = 2
	event.set_runtime_resources(pattern.projectile_def, pattern.phase_line)

	service.execute(event, battle_system)

	var projectile = null
	for _step in range(30):
		await process_frame
		projectile = _find_projectile_like_node(battle_system.get_world_root())
		if projectile != null:
			break

	var snapshot: Dictionary = projectile.get_debug_snapshot() if projectile != null else {}

	print("--- projectile preview probe ---")
	print("found=%s trail=%s speed=%.1f collision=%.1f detection=%.1f body_offset=%s" % [
		projectile != null,
		snapshot.get("trail_point_count", 0),
		float(snapshot.get("speed", 0.0)),
		float(snapshot.get("collision_radius", 0.0)),
		float(snapshot.get("detection_radius", 0.0)),
		snapshot.get("body_offset", Vector2.ZERO)
	])

	battle_system.end_editor_preview()
	battle_system.queue_free()
	quit()

func _find_projectile_like_node(node: Node):
	for child in node.get_children():
		if child == null:
			continue
		if child.has_method("initialize_from_shot") and child.has_method("get_debug_snapshot") and child.has_node("ProjectileBody"):
			return child
		var nested = _find_projectile_like_node(child)
		if nested != null:
			return nested
	return null
