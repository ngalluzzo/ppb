class_name ShotResolver
extends RefCounted

const ShotShooterContextScript = preload("res://weapon/shot/shot_shooter_context.gd")

func resolve(
	command: FireCommand,
	shooter_context,
	cannon: Cannon,
	pattern: ShotPattern,
	shot_id: int,
	weather_controller = null
) -> ShotEvent:
	var event: ShotEvent = ShotEvent.new()
	if command == null or shooter_context == null or cannon == null or pattern == null:
		return event

	var resolved_context = _coerce_shooter_context(shooter_context)
	if resolved_context == null:
		return event

	var resolved_angle: float = cannon.get_clamped_elevation_degrees(command.requested_angle_degrees)
	var resolved_power: float = clampf(
		command.requested_power,
		cannon.cannon_def.min_power,
		cannon.cannon_def.max_power
	)
	var aim_direction: Vector2 = cannon.get_aim_direction_for_degrees(resolved_angle)

	event.shot_id = shot_id
	event.shooter_id = command.shooter_id if command.shooter_id != "" else resolved_context.combatant_id
	event.shot_slot = command.shot_slot
	event.muzzle_position = cannon.get_muzzle_position()
	event.aim_direction = aim_direction
	event.resolved_power = resolved_power
	event.base_velocity = aim_direction * (resolved_power * pattern.arc_config.power_scale)
	event.created_frame = Engine.get_process_frames()
	event.projectile_count = pattern.unit_count
	event.stagger_delay = pattern.stagger_delay
	event.unit_spacing = pattern.unit_spacing
	event.max_range = pattern.max_range
	event.gravity = pattern.arc_config.gravity
	event.power_scale = pattern.arc_config.power_scale
	event.rng_seed = int(hash("%s:%s:%s" % [event.shot_id, event.shooter_id, command.local_frame]))
	event.facing_direction = resolved_context.facing_direction
	event.team_index = resolved_context.team_index
	event.set_runtime_resources(pattern.projectile_def, pattern.phase_line)
	event.wind_vector = Vector2.ZERO

	if weather_controller != null:
		var weather_ctx = weather_controller.build_ballistics_context(event)
		if weather_ctx != null:
			event.base_velocity = weather_ctx.base_velocity
			event.gravity = weather_ctx.gravity
			event.wind_vector = weather_ctx.wind_vector

	return event

func _coerce_shooter_context(shooter_context):
	if shooter_context == null:
		return null
	return ShotShooterContextScript.new(
		shooter_context.combatant_id,
		shooter_context.team_index,
		shooter_context.facing_direction
	)
