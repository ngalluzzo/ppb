class_name BattleTurnRules
extends RefCounted

static func begin_action_turn(state: BattleRuntimeState, controller_count: int) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	if controller_count <= 0:
		next_state.active_index = 0
		next_state.current_phase = BattleRuntimeState.Phase.WAITING
		next_state.projectiles_in_flight = 0
		return next_state
	next_state.active_index = posmod(next_state.active_index, controller_count)
	next_state.current_phase = BattleRuntimeState.Phase.ACTION
	next_state.projectiles_in_flight = 0
	next_state.turn_index += 1
	return next_state

static func on_shot_submitted(state: BattleRuntimeState, projectile_count: int) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	next_state.current_phase = BattleRuntimeState.Phase.RESOLVING
	next_state.projectiles_in_flight += max(projectile_count, 1)
	return next_state

static func on_projectile_resolved(state: BattleRuntimeState) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	next_state.projectiles_in_flight = max(next_state.projectiles_in_flight - 1, 0)
	if next_state.projectiles_in_flight == 0:
		next_state.current_phase = BattleRuntimeState.Phase.TURN_END
	return next_state

static func on_turn_timeout(state: BattleRuntimeState) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	if next_state.current_phase == BattleRuntimeState.Phase.ACTION:
		next_state.current_phase = BattleRuntimeState.Phase.TURN_END
	return next_state

static func advance_to_next_controller(state: BattleRuntimeState, controller_count: int) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	next_state.projectiles_in_flight = 0
	if controller_count <= 0:
		next_state.active_index = 0
		next_state.current_phase = BattleRuntimeState.Phase.WAITING
		return next_state
	next_state.current_phase = BattleRuntimeState.Phase.TURN_END
	next_state.active_index = (next_state.active_index + 1) % controller_count
	return next_state

static func on_controller_removed(
	state: BattleRuntimeState,
	removed_index: int,
	remaining_controller_count: int
) -> BattleRuntimeState:
	var next_state: BattleRuntimeState = state.copy()
	if remaining_controller_count <= 0:
		next_state.active_index = 0
		next_state.current_phase = BattleRuntimeState.Phase.WAITING
		next_state.projectiles_in_flight = 0
		return next_state
	if removed_index >= 0 and removed_index < next_state.active_index:
		next_state.active_index -= 1
	if next_state.active_index >= remaining_controller_count:
		next_state.active_index = 0
	return next_state
