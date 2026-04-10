class_name MobileControlRules
extends RefCounted

const MobileControllerStateScript = preload("res://mobile/controls/logic/mobile_controller_state.gd")

static func create_initial_state(
	initial_angle: float,
	initial_grounded: bool,
	initial_shot_slot: StringName = &"shot_1"
) -> MobileControllerState:
	return MobileControllerStateScript.new(
		false,
		initial_shot_slot,
		initial_angle,
		0.0,
		false,
		0.0,
		0.0,
		0,
		initial_grounded,
		false
	)

static func set_active(state: MobileControllerState, active: bool) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	next_state.is_active = active
	if not active:
		next_state.move_direction = 0
	return next_state

static func resolve_selected_slot(
	current_slot: StringName,
	requested_slot: StringName,
	requested_is_valid: bool,
	fallback_slot: StringName = &"shot_1",
	fallback_is_valid: bool = true
) -> StringName:
	if requested_slot == StringName():
		return current_slot
	if requested_is_valid:
		return requested_slot
	if fallback_is_valid:
		return fallback_slot
	return current_slot

static func apply_aim(
	state: MobileControllerState,
	aim_delta: float,
	cannon_def: CannonDefinition
) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	if next_state.charging or is_zero_approx(aim_delta) or cannon_def == null:
		return next_state
	next_state.current_angle = clampf(
		next_state.current_angle + aim_delta,
		cannon_def.min_angle,
		cannon_def.max_angle
	)
	return next_state

static func resolve_move_direction(state: MobileControllerState, requested_move_direction: int) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	next_state.move_direction = 0 if next_state.charging else clampi(requested_move_direction, -1, 1)
	return next_state

static func apply_locomotion_result(
	state: MobileControllerState,
	movement_result: MobileMovementResult
) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	if movement_result == null:
		return next_state
	next_state.remaining_thrust = maxf(0.0, next_state.remaining_thrust - movement_result.horizontal_distance_spent)
	next_state.grounded = movement_result.grounded
	next_state.moving = movement_result.moving
	return next_state

static func reset_movement_budget(
	state: MobileControllerState,
	thrust: float,
	grounded: bool
) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	next_state.max_thrust = maxf(0.0, thrust)
	next_state.remaining_thrust = next_state.max_thrust
	next_state.grounded = grounded
	next_state.moving = false
	return next_state

static func can_begin_charge(
	state: MobileControllerState,
	firing_can_fire: bool,
	stationary_for_actions: bool
) -> bool:
	if state == null:
		return false
	return (
		not state.charging
		and firing_can_fire
		and state.grounded
		and stationary_for_actions
	)

static func begin_charge(state: MobileControllerState, min_power: float) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	next_state.charging = true
	next_state.current_power = min_power
	next_state.move_direction = 0
	return next_state

static func advance_charge(
	state: MobileControllerState,
	charge_rate: float,
	max_power: float,
	delta: float,
	charge_rate_scalar: float
) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	if not next_state.charging:
		return next_state
	next_state.current_power = minf(
		next_state.current_power + (charge_rate * charge_rate_scalar * delta),
		max_power
	)
	return next_state

static func clear_charge(state: MobileControllerState) -> MobileControllerState:
	var next_state: MobileControllerState = state.copy()
	next_state.charging = false
	next_state.current_power = 0.0
	next_state.move_direction = 0
	return next_state

static func should_cancel_charge_for_support_loss(state: MobileControllerState) -> bool:
	return state != null and state.charging and not state.grounded

static func can_control(state: MobileControllerState) -> bool:
	return state != null and state.is_active

static func can_fire(
	state: MobileControllerState,
	firing_can_fire: bool,
	stationary_for_actions: bool
) -> bool:
	if state == null:
		return false
	return state.is_active and firing_can_fire and state.grounded and stationary_for_actions
