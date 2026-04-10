class_name ProjectileMotionRules
extends RefCounted

static func begin_frame(
	state: ProjectileRuntimeState,
	current_velocity: Vector2,
	shot_event: ShotEvent,
	delta: float
) -> Dictionary:
	var next_state: ProjectileRuntimeState = state.copy() if state != null else ProjectileRuntimeState.new()
	next_state.spin_time += delta
	var next_velocity: Vector2 = current_velocity
	if shot_event != null:
		next_velocity += shot_event.wind_vector * delta
		next_velocity.y += shot_event.gravity * delta
	return {
		"state": next_state,
		"velocity": next_velocity,
	}

static func finish_frame(
	state: ProjectileRuntimeState,
	current_position: Vector2,
	shot_event: ShotEvent
) -> Dictionary:
	var next_state: ProjectileRuntimeState = state.copy() if state != null else ProjectileRuntimeState.new()
	next_state.distance_traveled += current_position.distance_to(next_state.prev_position)
	next_state.prev_position = current_position
	var raw_progress: float = 0.0
	if shot_event != null and shot_event.max_range > 0.0:
		raw_progress = next_state.distance_traveled / shot_event.max_range
	return {
		"state": next_state,
		"raw_progress": raw_progress,
		"progress": clamp(raw_progress, 0.0, 1.0),
	}

static func compute_body_rotation(current_velocity: Vector2) -> Variant:
	if current_velocity.length() <= 0.0:
		return null
	return current_velocity.angle()
