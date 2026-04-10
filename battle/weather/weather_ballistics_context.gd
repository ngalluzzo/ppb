class_name WeatherBallisticsContext
extends RefCounted

var base_velocity: Vector2 = Vector2.ZERO
var gravity: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT
var wind_vector: Vector2 = Vector2.ZERO
var launch_speed: float = 0.0
var power_scalar: float = 1.0

func _init(
	p_base_velocity: Vector2 = Vector2.ZERO,
	p_gravity: float = 0.0,
	p_aim_direction: Vector2 = Vector2.RIGHT,
	p_wind_vector: Vector2 = Vector2.ZERO,
	p_launch_speed: float = 0.0,
	p_power_scalar: float = 1.0
) -> void:
	base_velocity = p_base_velocity
	gravity = p_gravity
	aim_direction = p_aim_direction
	wind_vector = p_wind_vector
	launch_speed = p_launch_speed
	power_scalar = p_power_scalar
