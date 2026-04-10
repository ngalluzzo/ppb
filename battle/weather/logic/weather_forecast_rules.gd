class_name WeatherForecastRules
extends RefCounted

const WeatherConfigResolverScript = preload("res://battle/weather/logic/weather_config_resolver.gd")
const WeatherDefinitionScript = preload("res://battle/weather/resources/weather_definition.gd")
const WeatherEventInstanceScript = preload("res://battle/weather/weather_event_instance.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")

static func build_forecast_queue(config: MatchWeatherConfig, seed: int) -> Array:
	var pool = WeatherConfigResolverScript.resolve_forecast_pool(config)
	var forecast_length: int = WeatherConfigResolverScript.resolve_forecast_length(config)
	var queue: Array = []
	if pool == null or forecast_length <= 0:
		return queue
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for index in range(forecast_length):
		var definition: Resource = pool.pick_weather(rng)
		if not WeatherResourceValidationScript.matches_script(definition, WeatherDefinitionScript):
			continue
		var entry_seed := int(hash("%s:%s" % [seed, index]))
		queue.append(
			WeatherEventInstanceScript.new(
				definition,
				maxi(1, definition.duration_turns),
				entry_seed,
				definition.modifiers.duplicate()
			)
		)
	return queue

static func advance_for_turn(state: WeatherRuntimeState, turn_index: int) -> Dictionary:
	var next_active = _advance_active_event(state.active_event)
	var next_queue: Array = _duplicate_queue(state.forecast_queue)
	var forecast_advanced: bool = false
	if next_active == null and _is_event_turn(state.config, turn_index):
		var activation := _activate_next_forecast_entry(next_queue, state.seed, turn_index)
		next_active = activation.active_event
		forecast_advanced = activation.forecast_advanced
	return {
		"active_event": next_active,
		"forecast_queue": next_queue,
		"forecast_advanced": forecast_advanced,
	}

static func _advance_active_event(active_event):
	if active_event == null:
		return null
	var next_event = active_event.copy()
	next_event.remaining_turns -= 1
	if next_event.remaining_turns <= 0:
		return null
	return next_event

static func _activate_next_forecast_entry(queue: Array, seed: int, turn_index: int) -> Dictionary:
	if queue.is_empty():
		return {
			"active_event": null,
			"forecast_advanced": false,
		}
	var next_entry = queue.pop_front()
	if next_entry == null:
		return {
			"active_event": null,
			"forecast_advanced": false,
		}
	return {
		"active_event": WeatherEventInstanceScript.new(
			next_entry.definition,
			next_entry.remaining_turns,
			int(hash("%s:%s:%s" % [seed, turn_index, next_entry.event_seed])),
			next_entry.resolved_modifiers.duplicate()
		),
		"forecast_advanced": true,
	}

static func _duplicate_queue(queue: Array) -> Array:
	var duplicate: Array = []
	for entry in queue:
		duplicate.append(entry.copy() if entry != null else null)
	return duplicate

static func _is_event_turn(config: MatchWeatherConfig, turn_index: int) -> bool:
	return turn_index >= 0 and turn_index % WeatherConfigResolverScript.resolve_event_interval(config) == 0
