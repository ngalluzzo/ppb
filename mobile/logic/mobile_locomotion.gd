class_name MobileLocomotion
extends RefCounted

static func prepare_motion(
	state: MobilePhysicsState,
	mobile_def: MobileDefinition,
	move_direction: int,
	remaining_thrust: float,
	delta: float
) -> MobilePhysicsState:
	var next_state: MobilePhysicsState = state.copy()
	next_state.step_attempted = false
	next_state.step_succeeded = false

	var intended_move_direction := clampi(move_direction, -1, 1)
	if next_state.grounded and intended_move_direction != 0:
		next_state.facing_direction = intended_move_direction

	next_state.velocity.y = minf(
		next_state.velocity.y + mobile_def.gravity * delta,
		mobile_def.max_fall_speed
	)

	if next_state.grounded:
		if intended_move_direction != 0 and remaining_thrust > 0.0:
			var target_velocity_x := mobile_def.walk_speed * float(intended_move_direction)
			next_state.velocity.x = move_toward(
				next_state.velocity.x,
				target_velocity_x,
				mobile_def.ground_acceleration * delta
			)
		else:
			next_state.velocity.x = move_toward(
				next_state.velocity.x,
				0.0,
				mobile_def.ground_deceleration * delta
			)

	return next_state

static func compute_horizontal_spend(
	remaining_thrust: float,
	move_direction: int,
	grounded: bool,
	previous_x: float,
	current_x: float
) -> float:
	if not grounded or move_direction == 0 or remaining_thrust <= 0.0:
		return 0.0
	return minf(remaining_thrust, absf(current_x - previous_x))

static func compute_landing_speed(
	was_initialized: bool,
	was_grounded: bool,
	grounded: bool,
	previous_vertical_speed: float
) -> float:
	if was_initialized and not was_grounded and grounded:
		return absf(previous_vertical_speed)
	return 0.0

static func took_support_loss(
	was_initialized: bool,
	was_grounded: bool,
	grounded: bool
) -> bool:
	return was_initialized and was_grounded and not grounded

static func finalize_motion(
	state: MobilePhysicsState,
	actual_velocity: Vector2,
	grounded: bool,
	move_epsilon: float,
	step_attempted: bool,
	step_succeeded: bool
) -> MobilePhysicsState:
	var next_state: MobilePhysicsState = state.copy()
	next_state.velocity = actual_velocity
	next_state.grounded = grounded
	next_state.moving = grounded and absf(actual_velocity.x) > move_epsilon
	next_state.locomotion_initialized = true
	next_state.step_attempted = step_attempted
	next_state.step_succeeded = step_succeeded
	return next_state

static func is_stationary_for_actions(state: MobilePhysicsState, move_epsilon: float) -> bool:
	if state == null:
		return false
	return state.grounded and absf(state.velocity.x) <= move_epsilon and absf(state.velocity.y) <= move_epsilon
