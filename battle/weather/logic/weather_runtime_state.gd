class_name WeatherRuntimeState
extends RefCounted

var config: Resource
var seed: int = 0
var turn_index: int = -1
var wind_vector: Vector2 = Vector2.ZERO
var forecast_queue: Array = []
var active_event

func _init(
	p_config: Resource = null,
	p_seed: int = 0,
	p_turn_index: int = -1,
	p_wind_vector: Vector2 = Vector2.ZERO,
	p_forecast_queue: Array = [],
	p_active_event = null
) -> void:
	config = p_config
	seed = p_seed
	turn_index = p_turn_index
	wind_vector = p_wind_vector
	forecast_queue = p_forecast_queue
	active_event = p_active_event
