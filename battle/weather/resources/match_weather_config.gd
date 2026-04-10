class_name MatchWeatherConfig
extends Resource

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const ClimateDefinitionScript = preload("res://battle/weather/resources/climate_definition.gd")
const ForecastPoolScript = preload("res://battle/weather/resources/forecast_pool.gd")

enum WindVariationMode {
	STATIC_NEUTRAL,
	RANDOM_EACH_TURN
}

var _climate: Resource
@export var climate: Resource:
	get:
		return _climate
	set(value):
		_climate = WeatherResourceValidationScript.require_resource(
			value,
			ClimateDefinitionScript,
			"ClimateDefinition",
			"MatchWeatherConfig.climate"
		)
@export var forecast_length: int = 0
@export var event_interval_turns: int = 0
@export var wind_variation_mode: WindVariationMode = WindVariationMode.RANDOM_EACH_TURN
var _allowed_forecast_pool_override: Resource
@export var allowed_forecast_pool_override: Resource:
	get:
		return _allowed_forecast_pool_override
	set(value):
		_allowed_forecast_pool_override = WeatherResourceValidationScript.require_resource(
			value,
			ForecastPoolScript,
			"ForecastPool",
			"MatchWeatherConfig.allowed_forecast_pool_override"
		)
@export var wind_min_strength_override: float = -1.0
@export var wind_max_strength_override: float = -1.0
