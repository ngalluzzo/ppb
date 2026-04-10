class_name MobileMovementResult
extends RefCounted

var horizontal_distance_spent: float
var grounded: bool
var moving: bool
var landing_speed: float
var took_support_loss: bool
var facing_direction: int

func _init(
	p_horizontal_distance_spent: float = 0.0,
	p_grounded: bool = false,
	p_moving: bool = false,
	p_landing_speed: float = 0.0,
	p_took_support_loss: bool = false,
	p_facing_direction: int = 1
) -> void:
	horizontal_distance_spent = p_horizontal_distance_spent
	grounded = p_grounded
	moving = p_moving
	landing_speed = p_landing_speed
	took_support_loss = p_took_support_loss
	facing_direction = p_facing_direction
