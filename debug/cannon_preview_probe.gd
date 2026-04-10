extends SceneTree

const BattleSystemScene = preload("res://battle/battle_system.tscn")
const CannonScene = preload("res://weapon/cannon/cannon.tscn")
const ShotExecutionServiceScript = preload("res://weapon/shot/shot_execution_service.gd")

func _init() -> void:
	print("--- cannon preview probe ---")

	var battle_system := BattleSystemScene.instantiate() as BattleSystem
	root.add_child(battle_system)
	await process_frame
	battle_system.begin_editor_preview("Cannon Preview Probe")

	var cannon := CannonScene.instantiate() as Cannon
	root.add_child(cannon)

	var cannon_def := CannonDefinition.new()
	cannon_def.name = "Probe Cannon"
	cannon_def.min_angle = 10.0
	cannon_def.max_angle = 80.0
	cannon_def.initial_angle = 45.0
	cannon_def.min_power = 10.0
	cannon_def.max_power = 100.0
	cannon_def.muzzle_offset = Vector2(32.0, 0.0)
	cannon.cannon_def = cannon_def
	cannon.facing_direction = -1
	cannon.editor_preview_enabled = true
	cannon.editor_preview_slot = &"shot_2"
	cannon.editor_preview_power = 75.0
	cannon.editor_preview_shooter_id = "preview_cannon"
	cannon.editor_preview_team_index = 3
	cannon.editor_preview_facing_direction = -1

	var projectile_def := ProjectileDefinition.new()
	projectile_def.name = "probe projectile"
	projectile_def.collision_radius = 8.0
	projectile_def.frame_size = Vector2i(16, 16)
	projectile_def.frame_count = 1
	projectile_def.animation_speed = 0.0
	projectile_def.impact_def = ImpactDefinition.new()
	projectile_def.impact_def.damage = 20.0
	projectile_def.impact_def.radius = 8.0
	projectile_def.impact_def.drill_power = 0.0

	var arc_config := ArcConfig.new()
	arc_config.gravity = 500.0
	arc_config.power_scale = 4.0
	arc_config.wind_factor = 1.0

	var shot_pattern := ShotPattern.new()
	shot_pattern.projectile_def = projectile_def
	shot_pattern.arc_config = arc_config
	shot_pattern.unit_count = 1
	shot_pattern.stagger_delay = 0.0
	shot_pattern.unit_spacing = 0.0
	shot_pattern.max_range = 1200.0
	cannon.editor_preview_shot_pattern = shot_pattern

	await process_frame

	var command := FireCommand.new("ignored", &"shot_2", 120.0, 150.0, 7)
	var event := cannon.build_editor_preview_shot_event(command, battle_system.get_weather_controller())
	assert(event != null)
	assert(event.shot_slot == &"shot_2")
	assert(event.shooter_id == "ignored")
	assert(event.team_index == 3)
	assert(event.facing_direction == -1)
	assert(is_equal_approx(event.resolved_power, 100.0))
	assert(event.aim_direction.x < 0.0)
	assert(event.projectile_count == 1)
	assert(event.projectile_definition == projectile_def)

	var execution_service := ShotExecutionServiceScript.new()
	root.add_child(execution_service)
	execution_service.execute(event, battle_system)

	var found_projectile := false
	for _frame in 30:
		await process_frame
		for child in battle_system.get_world_root().get_children():
			if child is Projectile:
				found_projectile = true
				break
		if found_projectile:
			break

	var snapshot := cannon.get_debug_snapshot()
	print(
		"ready=%s preview=%s slot=%s power=%.1f facing=%d projectile=%s muzzle=%s" % [
			cannon.is_editor_preview_ready(),
			snapshot.preview_enabled,
			snapshot.preview_slot,
			snapshot.preview_power,
			snapshot.facing_direction,
			found_projectile,
			snapshot.muzzle_position
		]
	)

	battle_system.end_editor_preview()
	quit()
