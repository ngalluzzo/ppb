class_name ProjectileRuntimeState
extends RefCounted

var spin_time: float = 0.0
var distance_traveled: float = 0.0
var prev_position: Vector2 = Vector2.ZERO
var active_body_offset: Vector2 = Vector2.ZERO

func _init(
	p_spin_time: float = 0.0,
	p_distance_traveled: float = 0.0,
	p_prev_position: Vector2 = Vector2.ZERO,
	p_active_body_offset: Vector2 = Vector2.ZERO
) -> void:
	spin_time = p_spin_time
	distance_traveled = p_distance_traveled
	prev_position = p_prev_position
	active_body_offset = p_active_body_offset

func copy() -> ProjectileRuntimeState:
	return ProjectileRuntimeState.new(
		spin_time,
		distance_traveled,
		prev_position,
		active_body_offset
	)
