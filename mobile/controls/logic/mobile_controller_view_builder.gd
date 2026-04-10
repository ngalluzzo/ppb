class_name MobileControllerViewBuilder
extends RefCounted

const MobileControlRulesScript = preload("res://mobile/controls/logic/mobile_control_rules.gd")
const MobileControlSourceSnapshotScript = preload("res://mobile/controls/logic/mobile_control_source_snapshot.gd")
const MobileControllerTargetContextScript = preload("res://mobile/controls/logic/mobile_controller_target_context.gd")

func build_control_state(
	state: MobileControllerState,
	mobile,
	cannon_def: CannonDefinition,
	firing_can_fire: bool,
	stationary_for_actions: bool
) -> MobileControlState:
	var max_power := cannon_def.max_power if cannon_def != null else 0.0
	var facing_direction: int = mobile.facing_direction if mobile != null else 1
	var combatant_id: String = mobile.combatant_id if mobile != null else ""
	var can_control := MobileControlRulesScript.can_control(state)
	var can_fire := MobileControlRulesScript.can_fire(state, firing_can_fire, stationary_for_actions)
	return MobileControlState.new(
		combatant_id,
		state.current_angle if state != null else 0.0,
		state.current_power if state != null else 0.0,
		max_power,
		state.max_thrust if state != null else 0.0,
		state.remaining_thrust if state != null else 0.0,
		state.charging if state != null else false,
		state.grounded if state != null else false,
		state.moving if state != null else false,
		facing_direction,
		state.active_shot_slot if state != null else &"shot_1",
		can_control,
		can_fire
	)

func build_control_source_snapshot(
	state: MobileControllerState,
	mobile,
	cannon_def: CannonDefinition,
	firing_can_fire: bool,
	stationary_for_actions: bool
) -> MobileControlSourceSnapshot:
	var can_control := MobileControlRulesScript.can_control(state)
	var can_fire := MobileControlRulesScript.can_fire(state, firing_can_fire, stationary_for_actions)
	return MobileControlSourceSnapshotScript.new(
		mobile.combatant_id if mobile != null else "",
		mobile.team_index if mobile != null else -1,
		state.active_shot_slot if state != null else &"shot_1",
		state.current_angle if state != null else 0.0,
		state.current_power if state != null else 0.0,
		cannon_def.min_power if cannon_def != null else 0.0,
		cannon_def.max_power if cannon_def != null else 0.0,
		state.remaining_thrust if state != null else 0.0,
		state.max_thrust if state != null else 0.0,
		state.charging if state != null else false,
		state.grounded if state != null else false,
		state.moving if state != null else false,
		mobile.facing_direction if mobile != null else 1,
		can_control,
		can_fire,
		cannon_def.aim_speed if cannon_def != null else 0.0
	)

func build_target_context(mobile) -> MobileControllerTargetContext:
	return MobileControllerTargetContextScript.new(
		mobile.team_index if mobile != null else -1,
		mobile.combatant_id if mobile != null else "",
		mobile,
		mobile
	)
