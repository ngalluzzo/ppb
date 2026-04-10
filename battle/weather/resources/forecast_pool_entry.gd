class_name ForecastPoolEntry
extends Resource

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherDefinitionScript = preload("res://battle/weather/resources/weather_definition.gd")

var _weather: Resource
@export var weather: Resource:
	get:
		return _weather
	set(value):
		_weather = WeatherResourceValidationScript.require_resource(
			value,
			WeatherDefinitionScript,
			"WeatherDefinition",
			"ForecastPoolEntry.weather"
		)
@export var weight: float = 1.0
