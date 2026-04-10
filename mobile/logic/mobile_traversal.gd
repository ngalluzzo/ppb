class_name MobileTraversal
extends RefCounted

static func get_max_walkable_slope_radians(mobile_def: MobileDefinition) -> float:
	if mobile_def == null:
		return deg_to_rad(40.0)
	return deg_to_rad(clampf(mobile_def.max_walkable_slope_degrees, 0.0, 89.0))

static func is_surface_walkable(normal: Vector2, max_walkable_slope_radians: float) -> bool:
	if normal == Vector2.ZERO:
		return false
	return absf(normal.angle_to(Vector2.UP)) <= max_walkable_slope_radians + 0.001

static func can_attempt_step_up(
	state: MobilePhysicsState,
	mobile_def: MobileDefinition,
	move_direction: int,
	remaining_thrust: float,
	delta: float
) -> bool:
	if state == null or mobile_def == null:
		return false
	if not state.grounded or move_direction == 0:
		return false
	if remaining_thrust <= 0.0 or delta <= 0.0:
		return false
	if mobile_def.step_height <= 0.0:
		return false
	if is_zero_approx(state.velocity.x):
		return false
	return true

static func try_step_up(
	current_transform: Transform2D,
	horizontal_motion: Vector2,
	mobile_def: MobileDefinition,
	physics_queries: MobilePhysicsAdapter,
	floor_snap_length: float,
	max_walkable_slope_radians: float
) -> Vector2:
	if mobile_def == null or physics_queries == null:
		return Vector2.ZERO

	var probe_distance := maxf(absf(horizontal_motion.x), mobile_def.step_forward_probe)
	if probe_distance <= 0.0:
		return Vector2.ZERO

	var probe_motion := Vector2(signf(horizontal_motion.x) * probe_distance, 0.0)
	var forward_collision = physics_queries.get_surface_contact(current_transform, probe_motion)
	if forward_collision == null:
		return Vector2.ZERO
	if forward_collision.normal == Vector2.ZERO:
		return Vector2.ZERO
	if is_surface_walkable(forward_collision.normal, max_walkable_slope_radians):
		return Vector2.ZERO

	var max_step := int(ceil(mobile_def.step_height))
	for step_pixels in range(1, max_step + 1):
		var elevated_transform := current_transform
		elevated_transform.origin += Vector2.UP * float(step_pixels)
		if not physics_queries.can_occupy(elevated_transform):
			continue
			if not physics_queries.can_move(elevated_transform, probe_motion):
				continue

			var final_transform := elevated_transform
			final_transform.origin += probe_motion
			var support_motion := Vector2.DOWN * (float(step_pixels) + floor_snap_length + 2.0)
			var support_collision = physics_queries.get_surface_contact(final_transform, support_motion)
			if support_collision == null:
				continue
			if not is_surface_walkable(support_collision.normal, max_walkable_slope_radians):
				continue
			return Vector2.UP * float(step_pixels)

	return Vector2.ZERO
