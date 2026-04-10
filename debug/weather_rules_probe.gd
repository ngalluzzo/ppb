extends SceneTree

const MatchWeatherConfigScript = preload("res://battle/weather/resources/match_weather_config.gd")
const WeatherConfigResolverScript = preload("res://battle/weather/logic/weather_config_resolver.gd")
const WeatherForecastRulesScript = preload("res://battle/weather/logic/weather_forecast_rules.gd")
const WeatherModifierResolverScript = preload("res://battle/weather/logic/weather_modifier_resolver.gd")
const WeatherRuntimeStateScript = preload("res://battle/weather/logic/weather_runtime_state.gd")
const WeatherStatusRulesScript = preload("res://battle/weather/logic/weather_status_rules.gd")
const WeatherWindRulesScript = preload("res://battle/weather/logic/weather_wind_rules.gd")
const MobilePhysicsStateScript = preload("res://mobile/logic/mobile_physics_state.gd")
const ShotEventScript = preload("res://weapon/shot/shot_event.gd")

class FakeMobile:
	extends Node2D
	var combatant_id: String = ""
	var team_index: int = -1
	var _physics_state

class DummyController:
	extends RefCounted
	var _mobile

	func _init(p_mobile) -> void:
		_mobile = p_mobile

	class DummyTargetContext:
		extends RefCounted
		var mobile
		var team_index: int = -1
		var combatant_id: String = ""

		func _init(p_mobile) -> void:
			mobile = p_mobile
			team_index = p_mobile.team_index if p_mobile != null else -1
			combatant_id = p_mobile.combatant_id if p_mobile != null else ""

	func get_target_context():
		return DummyTargetContext.new(_mobile)

class DummyBattleSystem:
	extends RefCounted
	var _units: Array = []

	func _init(p_units: Array) -> void:
		_units = p_units

	func get_units() -> Array:
		return _units

func _init() -> void:
	call_deferred("_run")

func _make_probe_mobile(combatant_id: String, team_index: int):
	var mobile := FakeMobile.new()
	mobile.combatant_id = combatant_id
	mobile.team_index = team_index
	mobile._physics_state = MobilePhysicsStateScript.new(Vector2.ZERO, true, false, 1, false, false, false)
	return mobile

func _run() -> void:
	var config: MatchWeatherConfig = load("res://roster/weather/match_weather_default.tres")
	var seed: int = 424242
	var queue_a: Array = WeatherForecastRulesScript.build_forecast_queue(config, seed)
	var queue_b: Array = WeatherForecastRulesScript.build_forecast_queue(config, seed)
	var same_forecast: bool = _forecast_names(queue_a) == _forecast_names(queue_b)
	var wind_a: Vector2 = WeatherWindRulesScript.roll_wind_for_turn(config, seed, 3)
	var wind_b: Vector2 = WeatherWindRulesScript.roll_wind_for_turn(config, seed, 3)

	var state: WeatherRuntimeState = WeatherRuntimeStateScript.new(config, seed, -1, Vector2.ZERO, queue_a, null)
	state.wind_vector = WeatherWindRulesScript.roll_wind_for_turn(config, seed, 0)
	var turn_zero := WeatherForecastRulesScript.advance_for_turn(state, 0)
	state.turn_index = 0
	state.active_event = turn_zero.active_event
	state.forecast_queue = turn_zero.forecast_queue

	var shot_event := ShotEventScript.new()
	shot_event.base_velocity = Vector2(100.0, -40.0)
	shot_event.gravity = 98.0
	shot_event.aim_direction = Vector2(1.0, -0.4).normalized()
	var ballistics_ctx = WeatherModifierResolverScript.build_ballistics_context(state, shot_event)

	var unit = _make_probe_mobile("rules_probe_unit", 0)
	var controller := DummyController.new(unit)
	var battle_system := DummyBattleSystem.new([unit])
	var turn_start_apps: Array = WeatherStatusRulesScript.build_turn_start_status_applications(state, controller, battle_system)

	print("--- weather rules probe ---")
	print("forecast_length=%s interval=%s same_forecast=%s" % [
		WeatherConfigResolverScript.resolve_forecast_length(config),
		WeatherConfigResolverScript.resolve_event_interval(config),
		same_forecast
	])
	print("wind_repeatable=%s turn3_wind=%s active_turn0=%s advanced=%s" % [
		wind_a == wind_b,
		wind_a,
		_active_name(state.active_event),
		turn_zero.forecast_advanced
	])
	print("ballistics gravity=%s velocity=%s status_apps=%s" % [
		ballistics_ctx.gravity,
		ballistics_ctx.base_velocity,
		_status_names(turn_start_apps)
	])

	unit.free()
	quit()

func _forecast_names(queue: Array) -> Array[String]:
	var names: Array[String] = []
	for entry in queue:
		if entry == null or entry.definition == null:
			continue
		names.append(entry.definition.display_name)
	return names

func _active_name(active_event) -> String:
	if active_event == null or active_event.definition == null:
		return "clear"
	return active_event.definition.display_name

func _status_names(applications: Array) -> Array[String]:
	var names: Array[String] = []
	for application in applications:
		if application == null or application.status_definition == null:
			continue
		names.append(application.status_definition.display_name)
	return names
