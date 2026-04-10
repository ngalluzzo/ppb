class_name MobileFireCoordinator
extends RefCounted

const MobileControlRulesScript = preload("res://mobile/controls/logic/mobile_control_rules.gd")
const MobileFireOutcomeScript = preload("res://mobile/controls/logic/mobile_fire_outcome.gd")

func submit_fire(
	state: MobileControllerState,
	mobile,
	firing_mechanism,
	weather_controller = null,
	local_frame: int = 0
) -> MobileFireOutcome:
	var next_state: MobileControllerState = MobileControlRulesScript.clear_charge(state)
	if state == null or mobile == null or firing_mechanism == null:
		return MobileFireOutcomeScript.new(null, true, next_state)
	var command := FireCommand.new(
		mobile.combatant_id,
		state.active_shot_slot,
		state.current_angle,
		state.current_power,
		local_frame
	)
	var event: ShotEvent = firing_mechanism.submit_fire_command(command, mobile, weather_controller)
	if event == null:
		return MobileFireOutcomeScript.new(null, true, next_state)
	return MobileFireOutcomeScript.new(event, false, next_state)
