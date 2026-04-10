class_name ClimateDefinition
extends Resource

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const ForecastPoolScript = preload("res://battle/weather/resources/forecast_pool.gd")

@export var display_name: String = ""
@export var wind_min_strength: float = 0.0
@export var wind_max_strength: float = 0.0
var _allowed_forecast_pool: Resource
@export var allowed_forecast_pool: Resource:
	get:
		return _allowed_forecast_pool
	set(value):
		_allowed_forecast_pool = WeatherResourceValidationScript.require_resource(
			value,
			ForecastPoolScript,
			"ForecastPool",
			"ClimateDefinition.allowed_forecast_pool"
		)
@export var default_forecast_length: int = 5
@export var default_event_interval_turns: int = 2
@export var icon: Texture2D
@export var theme_color: Color = Color.WHITE
@export var background_tint: Color = Color(1.0, 1.0, 1.0, 0.0)
