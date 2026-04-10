extends SceneTree

const MobileControllerStateScript = preload("res://mobile/controls/logic/mobile_controller_state.gd")
const MobileControlRulesScript = preload("res://mobile/controls/logic/mobile_control_rules.gd")
const MobileControllerViewBuilderScript = preload("res://mobile/controls/logic/mobile_controller_view_builder.gd")
const MobileFireCoordinatorScript = preload("res://mobile/controls/logic/mobile_fire_coordinator.gd")
const MobilePhysicsStateScript = preload("res://mobile/logic/mobile_physics_state.gd")

class FakeMobile:
	extends RefCounted
	var combatant_id: String = ""
	var team_index: int = -1
	var facing_direction: int = 1
	var _physics_state

class DummyFiringMechanism:
	extends RefCounted
	var should_fire: bool = true

	func submit_fire_command(_command, _mobile, _weather_controller = null) -> ShotEvent:
		if not should_fire:
			return null
		var event := ShotEvent.new()
		event.shot_id = 77
		return event

func _init() -> void:
	call_deferred("_run")

func _make_probe_mobile():
	var mobile := FakeMobile.new()
	mobile.combatant_id = "probe_unit"
	mobile.team_index = 1
	mobile._physics_state = MobilePhysicsStateScript.new(Vector2.ZERO, true, false, -1, false, false, false)
	return mobile

func _run() -> void:
	var cannon_def := CannonDefinition.new()
	cannon_def.min_angle = 10.0
	cannon_def.max_angle = 80.0
	cannon_def.min_power = 5.0
	cannon_def.max_power = 100.0
	cannon_def.aim_speed = 60.0
	cannon_def.charge_rate = 50.0

	var state: MobileControllerState = MobileControlRulesScript.create_initial_state(45.0, true, &"shot_1")
	state = MobileControlRulesScript.set_active(state, true)
	state = MobileControlRulesScript.reset_movement_budget(state, 100.0, true)
	state = MobileControlRulesScript.apply_aim(state, 5.0, cannon_def)
	state = MobileControlRulesScript.begin_charge(state, cannon_def.min_power)
	state = MobileControlRulesScript.advance_charge(state, cannon_def.charge_rate, cannon_def.max_power, 0.5, 1.2)

	var probe_mobile = _make_probe_mobile()
	var fire_coordinator: MobileFireCoordinator = MobileFireCoordinatorScript.new()
	var fire_outcome: MobileFireOutcome = fire_coordinator.submit_fire(
		state,
		probe_mobile,
		DummyFiringMechanism.new(),
		null,
		123
	)

	var view_builder: MobileControllerViewBuilder = MobileControllerViewBuilderScript.new()
	var control_state: MobileControlState = view_builder.build_control_state(
		fire_outcome.next_state,
		probe_mobile,
		cannon_def,
		true,
		true
	)
	var control_snapshot: MobileControlSourceSnapshot = view_builder.build_control_source_snapshot(
		fire_outcome.next_state,
		probe_mobile,
		cannon_def,
		true,
		true
	)

	print("--- mobile controller probe ---")
	print("aim=%.1f thrust=%s power=%.1f charging=%s" % [
		state.current_angle,
		state.remaining_thrust,
		state.current_power,
		state.charging
	])
	print("fired=%s next_charging=%s snapshot_slot=%s can_fire=%s" % [
		fire_outcome.event != null,
		fire_outcome.next_state.charging if fire_outcome.next_state != null else true,
		String(control_snapshot.selected_shot_slot),
		control_state.can_fire
	])
	quit()
