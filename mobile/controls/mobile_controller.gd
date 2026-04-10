class_name MobileController
extends Node

const MobileControllerStateScript = preload("res://mobile/controls/logic/mobile_controller_state.gd")
const MobileControlRulesScript = preload("res://mobile/controls/logic/mobile_control_rules.gd")
const MobileFireCoordinatorScript = preload("res://mobile/controls/logic/mobile_fire_coordinator.gd")
const MobileControllerViewBuilderScript = preload("res://mobile/controls/logic/mobile_controller_view_builder.gd")

signal control_state_changed(state: MobileControlState)
signal shot_event_created(event: ShotEvent)
signal fired(event: ShotEvent)
signal activated(controller: MobileController)
signal deactivated(controller: MobileController)
signal charging_started
signal charge_canceled
signal status_view_states_changed(view_states: Array)

var _mobile: Mobile
var _control_source: MobileControlSource
var _battle_system: BattleSystem
var _state: MobileControllerState
var _fire_coordinator: MobileFireCoordinator = MobileFireCoordinatorScript.new()
var _view_builder: MobileControllerViewBuilder = MobileControllerViewBuilderScript.new()

func _ready() -> void:
	set_physics_process(false)

func setup(
	p_mobile: Mobile,
	p_control_source: MobileControlSource,
	p_battle_system: BattleSystem
) -> void:
	_mobile = p_mobile
	_battle_system = p_battle_system
	set_control_source(p_control_source)
	if _mobile == null:
		return
	_state = MobileControlRulesScript.create_initial_state(
		_get_current_cannon_angle(),
		_mobile.is_grounded(),
		&"shot_1"
	)
	_select_shot_slot(_state.active_shot_slot)
	_mobile.bind_controller(self)
	if not _mobile.status_view_states_changed.is_connected(_on_mobile_status_view_states_changed):
		_mobile.status_view_states_changed.connect(_on_mobile_status_view_states_changed)
	_emit_control_state_changed()
	_emit_status_view_states_changed()

func set_control_source(source: MobileControlSource) -> void:
	_control_source = source
	_emit_control_state_changed()

func set_active(active: bool) -> void:
	if _state != null and _state.is_active == active:
		return
	_state = _ensure_state()
	_state = MobileControlRulesScript.set_active(_state, active)
	set_physics_process(active)
	if not active:
		_cancel_charge()
	else:
		_reset_movement_budget()
	if active:
		activated.emit(self)
	else:
		deactivated.emit(self)
	_emit_control_state_changed()

func is_active() -> bool:
	return _state != null and _state.is_active

func get_status_view_states() -> Array:
	if _mobile == null:
		return []
	return _mobile.get_status_view_states()

func get_control_state() -> MobileControlState:
	return _view_builder.build_control_state(
		_ensure_state(),
		_mobile,
		_get_cannon_def(),
		_get_firing_can_fire(),
		_is_stationary_for_actions()
	)

func get_control_source_snapshot() -> MobileControlSourceSnapshot:
	return _view_builder.build_control_source_snapshot(
		_ensure_state(),
		_mobile,
		_get_cannon_def(),
		_get_firing_can_fire(),
		_is_stationary_for_actions()
	)

func get_target_context() -> MobileControllerTargetContext:
	return _view_builder.build_target_context(_mobile)

func get_follow_target() -> Node2D:
	var context := get_target_context()
	return context.follow_target if context != null else null

func get_traversal_debug_text() -> String:
	if _mobile == null:
		return "traversal: unavailable"
	return _mobile.get_traversal_debug_text()

func get_team_index() -> int:
	return _mobile.team_index if _mobile != null else -1

func get_combatant_id() -> String:
	return _mobile.combatant_id if _mobile != null else ""

func _physics_process(delta: float) -> void:
	if not is_active() or _mobile == null or _control_source == null:
		return
	var intent: MobileIntent = _control_source.gather_intent(get_control_source_snapshot(), delta)
	submit_intent(intent, delta)

func submit_intent(intent: MobileIntent, delta: float) -> void:
	if intent == null or _mobile == null:
		return
	_state = _ensure_state()
	if intent.selected_shot_slot != StringName() and intent.selected_shot_slot != _state.active_shot_slot:
		_select_shot_slot(intent.selected_shot_slot)

	var cannon_def := _get_cannon_def()
	if cannon_def != null and intent.aim_delta != 0.0 and not _state.charging:
		_state = MobileControlRulesScript.apply_aim(_state, intent.aim_delta, cannon_def)
		if _mobile.cannon != null:
			_mobile.cannon.set_elevation_degrees(_state.current_angle)

	var firing_mechanism: FiringMechanism = _get_firing_mechanism()
	if firing_mechanism == null:
		_emit_control_state_changed()
		return

	_state = MobileControlRulesScript.resolve_move_direction(_state, intent.move_direction)
	var movement_result := _mobile.step_locomotion(_state.move_direction, _state.remaining_thrust, delta)
	_state = MobileControlRulesScript.apply_locomotion_result(_state, movement_result)

	if MobileControlRulesScript.should_cancel_charge_for_support_loss(_state):
		_cancel_charge()
	if intent.begin_charge and intent.move_direction == 0:
		_begin_charge()
	if intent.continue_charge and _state.charging:
		_advance_charge(delta)
	if intent.release_fire and _state.charging:
		var outcome: MobileFireOutcome = _fire_coordinator.submit_fire(
			_state,
			_mobile,
			firing_mechanism,
			_battle_system.get_weather_controller() if _battle_system != null else null,
			Engine.get_process_frames()
		)
		_state = outcome.next_state if outcome != null and outcome.next_state != null else MobileControlRulesScript.clear_charge(_state)
		if outcome != null and outcome.charge_canceled:
			charge_canceled.emit()
		if outcome == null or outcome.event == null:
			_emit_control_state_changed()
			return
		if _battle_system != null:
			_battle_system.submit_shot_event(outcome.event)
		shot_event_created.emit(outcome.event)
		fired.emit(outcome.event)
		_emit_control_state_changed()
		return
	_emit_control_state_changed()

func _select_shot_slot(slot: StringName) -> void:
	if _mobile == null:
		return
	_state = _ensure_state()
	var requested_pattern := _mobile.get_shot_pattern(slot)
	var fallback_slot: StringName = &"shot_1"
	var fallback_pattern := _mobile.get_shot_pattern(fallback_slot)
	var resolved_slot: StringName = MobileControlRulesScript.resolve_selected_slot(
		_state.active_shot_slot,
		slot,
		requested_pattern != null,
		fallback_slot,
		fallback_pattern != null
	)
	var pattern: ShotPattern = requested_pattern if resolved_slot == slot else fallback_pattern
	if pattern == null:
		return
	_state.active_shot_slot = resolved_slot
	_cancel_charge()
	var firing_mechanism: FiringMechanism = _get_firing_mechanism()
	if firing_mechanism != null:
		firing_mechanism.set_active_shot_pattern(pattern, _state.active_shot_slot)

func _begin_charge() -> void:
	var cannon_def := _get_cannon_def()
	if cannon_def == null:
		return
	if not MobileControlRulesScript.can_begin_charge(
		_ensure_state(),
		_get_firing_can_fire(),
		_is_stationary_for_actions()
	):
		return
	_state = MobileControlRulesScript.begin_charge(_state, cannon_def.min_power)
	charging_started.emit()

func _advance_charge(delta: float) -> void:
	var cannon_def := _get_cannon_def()
	if cannon_def == null:
		return
	_state = MobileControlRulesScript.advance_charge(
		_ensure_state(),
		cannon_def.charge_rate,
		cannon_def.max_power,
		delta,
		_get_charge_rate_scalar()
	)

func _cancel_charge() -> void:
	_state = _ensure_state()
	if not _state.charging and is_zero_approx(_state.current_power):
		return
	var was_charging := _state.charging
	_state = MobileControlRulesScript.clear_charge(_state)
	if was_charging:
		charge_canceled.emit()

func _emit_control_state_changed() -> void:
	control_state_changed.emit(get_control_state())

func _emit_status_view_states_changed() -> void:
	status_view_states_changed.emit(get_status_view_states())

func _on_mobile_status_view_states_changed(_view_states: Array) -> void:
	_emit_status_view_states_changed()

func _reset_movement_budget() -> void:
	if _mobile == null or _mobile.stat_container == null:
		_state = MobileControlRulesScript.reset_movement_budget(_ensure_state(), 0.0, true)
		return
	_state = MobileControlRulesScript.reset_movement_budget(
		_ensure_state(),
		_mobile.stat_container.get_stat("thrust"),
		_mobile.is_grounded()
	)

func _get_charge_rate_scalar() -> float:
	if _battle_system == null or _battle_system.get_weather_controller() == null:
		return 1.0
	var ctx = _battle_system.get_weather_controller().build_control_context(self)
	if ctx == null:
		return 1.0
	return ctx.charge_rate_scalar

func _ensure_state() -> MobileControllerState:
	if _state == null:
		_state = MobileControlRulesScript.create_initial_state(0.0, true, &"shot_1")
	return _state

func _get_firing_mechanism() -> FiringMechanism:
	if _mobile == null or _mobile.cannon == null:
		return null
	return _mobile.cannon.firing_mechanism

func _get_firing_can_fire() -> bool:
	var firing_mechanism: FiringMechanism = _get_firing_mechanism()
	return firing_mechanism != null and firing_mechanism.can_fire()

func _get_cannon_def() -> CannonDefinition:
	if _mobile == null or _mobile.cannon == null:
		return null
	return _mobile.cannon.cannon_def

func _get_current_cannon_angle() -> float:
	if _mobile == null or _mobile.cannon == null:
		return 0.0
	return _mobile.cannon.get_elevation_degrees()

func _is_stationary_for_actions() -> bool:
	return _mobile != null and _mobile.is_stationary_for_actions()
