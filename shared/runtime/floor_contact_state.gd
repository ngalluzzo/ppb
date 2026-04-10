class_name FloorContactState
extends RefCounted

var grounded: bool = false
var floor_normal: Vector2 = Vector2.ZERO
var floor_angle: float = 0.0

func _init(
	p_grounded: bool = false,
	p_floor_normal: Vector2 = Vector2.ZERO,
	p_floor_angle: float = 0.0
) -> void:
	grounded = p_grounded
	floor_normal = p_floor_normal
	floor_angle = p_floor_angle
