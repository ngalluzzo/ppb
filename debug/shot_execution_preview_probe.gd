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
	battle_system.begin_editor_preview("Shot Exec Probe", weather_config, 11)

	var service: ShotExecutionService = ShotExecutionServiceScript.new()
	battle_system.add_child(service)

	var event := ShotEvent.new()
	event.shot_id = 101
	event.shooter_id = "probe"
	event.shot_slot = &"shot_1"
	event.muzzle_position = Vector2(100.0, 200.0)
	event.aim_direction = Vector2(1.0, -1.0).normalized()
	event.resolved_power = 24.0
	event.base_velocity = event.aim_direction * (24.0 * pattern.arc_config.power_scale)
	event.created_frame = 0
	event.projectile_count = 3
	event.stagger_delay = 0.02
	event.unit_spacing = pattern.unit_spacing
	event.max_range = pattern.max_range
	event.gravity = pattern.arc_config.gravity
	event.power_scale = pattern.arc_config.power_scale
	event.rng_seed = 1
	event.set_runtime_resources(pattern.projectile_def, pattern.phase_line)

	service.execute(event, battle_system)
	for _step in range(120):
		await process_frame
		var pending_snapshot: Dictionary = service.get_debug_snapshot()
		if int(pending_snapshot.get("spawned_count", 0)) >= event.projectile_count and int(pending_snapshot.get("active_executors", 0)) == 0:
			break

	var projectile_count := _count_projectiles(battle_system.get_world_root())
	var snapshot := service.get_debug_snapshot()

	print("--- shot execution preview probe ---")
	print("projectiles=%s mode=%s spawned=%s active_executors=%s" % [
		projectile_count,
		snapshot.get("mode", ""),
		snapshot.get("spawned_count", 0),
		snapshot.get("active_executors", 0)
	])

	service.cancel_active_executions()
	battle_system.end_editor_preview()
	battle_system.queue_free()
	quit()

func _count_projectiles(node: Node) -> int:
	var count := 0
	for child in node.get_children():
		if child == null:
			continue
		if child.has_method("initialize_from_shot") and child.has_node("ProjectileBody") and "projectile_index" in child:
			count += 1
		count += _count_projectiles(child)
	return count
