class_name MobilePhysicsState
extends RefCounted

var velocity: Vector2
var grounded: bool
var moving: bool
var facing_direction: int
var locomotion_initialized: bool
var step_attempted: bool
var step_succeeded: bool

func _init(
	p_velocity: Vector2 = Vector2.ZERO,
	p_grounded: bool = true,
	p_moving: bool = false,
	p_facing_direction: int = 1,
	p_locomotion_initialized: bool = false,
	p_step_attempted: bool = false,
	p_step_succeeded: bool = false
) -> void:
	velocity = p_velocity
	grounded = p_grounded
	moving = p_moving
	facing_direction = -1 if p_facing_direction < 0 else 1
	locomotion_initialized = p_locomotion_initialized
	step_attempted = p_step_attempted
	step_succeeded = p_step_succeeded

func copy() -> MobilePhysicsState:
	return MobilePhysicsState.new(
		velocity,
		grounded,
		moving,
		facing_direction,
		locomotion_initialized,
		step_attempted,
		step_succeeded
	)
