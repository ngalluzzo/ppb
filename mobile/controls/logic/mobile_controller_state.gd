class_name MobileControllerState
extends RefCounted

var is_active: bool = false
var active_shot_slot: StringName = &"shot_1"
var current_angle: float = 0.0
var current_power: float = 0.0
var charging: bool = false
var max_thrust: float = 0.0
var remaining_thrust: float = 0.0
var move_direction: int = 0
var grounded: bool = true
var moving: bool = false

func _init(
	p_is_active: bool = false,
	p_active_shot_slot: StringName = &"shot_1",
	p_current_angle: float = 0.0,
	p_current_power: float = 0.0,
	p_charging: bool = false,
	p_max_thrust: float = 0.0,
	p_remaining_thrust: float = 0.0,
	p_move_direction: int = 0,
	p_grounded: bool = true,
	p_moving: bool = false
) -> void:
	is_active = p_is_active
	active_shot_slot = p_active_shot_slot
	current_angle = p_current_angle
	current_power = p_current_power
	charging = p_charging
	max_thrust = p_max_thrust
	remaining_thrust = p_remaining_thrust
	move_direction = clampi(p_move_direction, -1, 1)
	grounded = p_grounded
	moving = p_moving

func copy() -> MobileControllerState:
	return MobileControllerState.new(
		is_active,
		active_shot_slot,
		current_angle,
		current_power,
		charging,
		max_thrust,
		remaining_thrust,
		move_direction,
		grounded,
		moving
	)
