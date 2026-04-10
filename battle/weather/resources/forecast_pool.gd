class_name ForecastPool
extends Resource

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const ForecastPoolEntryScript = preload("res://battle/weather/resources/forecast_pool_entry.gd")

var _entries: Array[Resource] = []
@export var entries: Array[Resource]:
	get:
		return _entries
	set(value):
		_entries = WeatherResourceValidationScript.filter_resources(
			value,
			ForecastPoolEntryScript,
			"ForecastPoolEntry",
			"ForecastPool.entries"
		)

func pick_weather(rng: RandomNumberGenerator):
	if entries.is_empty():
		return null
	var total_weight := 0.0
	for entry in entries:
		if not WeatherResourceValidationScript.matches_script(entry, ForecastPoolEntryScript) or entry.weather == null:
			continue
		total_weight += maxf(0.0, entry.weight)
	if total_weight <= 0.0:
		return null

	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for entry in entries:
		if not WeatherResourceValidationScript.matches_script(entry, ForecastPoolEntryScript) or entry.weather == null:
			continue
		accumulated += maxf(0.0, entry.weight)
		if roll <= accumulated:
			return entry.weather
	for index in range(entries.size() - 1, -1, -1):
		var entry = entries[index]
		if WeatherResourceValidationScript.matches_script(entry, ForecastPoolEntryScript) and entry.weather != null:
			return entry.weather
	return null
