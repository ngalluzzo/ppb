class_name WeatherState
extends RefCounted

var turn_index: int = 0
var wind_vector: Vector2 = Vector2.ZERO
var active_event
var forecast: Array = []

func _init(
	p_turn_index: int = 0,
	p_wind_vector: Vector2 = Vector2.ZERO,
	p_active_event = null,
	p_forecast: Array = []
) -> void:
	turn_index = p_turn_index
	wind_vector = p_wind_vector
	active_event = p_active_event
	forecast = p_forecast

static func neutral() -> WeatherState:
	return WeatherState.new(0, Vector2.ZERO, null, [])
