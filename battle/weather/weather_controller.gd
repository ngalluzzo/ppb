class_name WeatherController
extends Node

const MatchWeatherConfigScript = preload("res://battle/weather/resources/match_weather_config.gd")
const WeatherConfigResolverScript = preload("res://battle/weather/logic/weather_config_resolver.gd")
const WeatherForecastRulesScript = preload("res://battle/weather/logic/weather_forecast_rules.gd")
const WeatherModifierResolverScript = preload("res://battle/weather/logic/weather_modifier_resolver.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherRuntimeStateScript = preload("res://battle/weather/logic/weather_runtime_state.gd")
const WeatherStateScript = preload("res://battle/weather/weather_state.gd")
const WeatherStatusRulesScript = preload("res://battle/weather/logic/weather_status_rules.gd")
const WeatherWindRulesScript = preload("res://battle/weather/logic/weather_wind_rules.gd")

signal weather_state_changed(state)
signal forecast_advanced(state)
signal wind_changed(state)

var _runtime_state: WeatherRuntimeState

func setup(config, p_seed: int) -> void:
	var resolved_config = WeatherResourceValidationScript.require_resource(
		config,
		MatchWeatherConfigScript,
		"MatchWeatherConfig",
		"WeatherController.setup(config)"
	)
	_runtime_state = WeatherRuntimeStateScript.new(resolved_config, p_seed, -1, Vector2.ZERO, [], null)
	_runtime_state.forecast_queue = WeatherForecastRulesScript.build_forecast_queue(resolved_config, p_seed)
	_runtime_state.wind_vector = WeatherWindRulesScript.roll_wind_for_turn(resolved_config, p_seed, 0)
	_emit_initial_state()

func on_turn_started(turn_index: int) -> void:
	if _runtime_state == null:
		return
	var previous_wind := _runtime_state.wind_vector
	var transition := WeatherForecastRulesScript.advance_for_turn(_runtime_state, turn_index)
	_runtime_state.turn_index = turn_index
	_runtime_state.active_event = transition.active_event
	_runtime_state.forecast_queue = transition.forecast_queue
	_runtime_state.wind_vector = WeatherWindRulesScript.roll_wind_for_turn(_runtime_state.config, _runtime_state.seed, turn_index)
	if transition.forecast_advanced:
		forecast_advanced.emit(get_weather_state())
	if previous_wind != _runtime_state.wind_vector:
		wind_changed.emit(get_weather_state())
	weather_state_changed.emit(get_weather_state())

func get_weather_state():
	if _runtime_state == null:
		return WeatherStateScript.neutral()
	var active_copy
	if _runtime_state.active_event != null:
		active_copy = _runtime_state.active_event.copy()
	var forecast_copy: Array = []
	for entry in _runtime_state.forecast_queue:
		if entry != null:
			forecast_copy.append(entry.copy())
	return WeatherStateScript.new(_runtime_state.turn_index, _runtime_state.wind_vector, active_copy, forecast_copy)

func get_active_modifiers() -> Array:
	return WeatherModifierResolverScript.get_active_modifiers(_runtime_state)

func build_ballistics_context(shot_event: ShotEvent):
	return WeatherModifierResolverScript.build_ballistics_context(_runtime_state, shot_event)

func build_impact_context(event: ImpactEvent):
	return WeatherModifierResolverScript.build_impact_context(_runtime_state, event)

func build_control_context(_controller):
	return WeatherModifierResolverScript.build_control_context(_runtime_state)

func build_turn_start_status_applications(controller, battle_system) -> Array:
	return WeatherStatusRulesScript.build_turn_start_status_applications(_runtime_state, controller, battle_system)

func build_impact_status_applications(event: ImpactEvent, battle_system, splash_radius: float = -1.0) -> Array:
	return WeatherStatusRulesScript.build_impact_status_applications(_runtime_state, event, battle_system, splash_radius)

func _emit_initial_state() -> void:
	var state
	state = get_weather_state()
	wind_changed.emit(state)
	weather_state_changed.emit(state)
