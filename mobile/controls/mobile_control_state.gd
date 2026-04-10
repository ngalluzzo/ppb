class_name MobileControlState
extends RefCounted

var combatant_id: String
var current_angle: float
var current_power: float
var max_power: float
var max_thrust: float
var remaining_thrust: float
var charging: bool
var grounded: bool
var moving: bool
var facing_direction: int
var selected_shot_slot: StringName
var can_control: bool
var can_fire: bool

func _init(
	p_combatant_id: String = "",
	p_current_angle: float = 0.0,
	p_current_power: float = 0.0,
	p_max_power: float = 0.0,
	p_max_thrust: float = 0.0,
	p_remaining_thrust: float = 0.0,
	p_charging: bool = false,
	p_grounded: bool = false,
	p_moving: bool = false,
	p_facing_direction: int = 1,
	p_selected_shot_slot: StringName = &"shot_1",
	p_can_control: bool = false,
	p_can_fire: bool = false
) -> void:
	combatant_id = p_combatant_id
	current_angle = p_current_angle
	current_power = p_current_power
	max_power = p_max_power
	max_thrust = p_max_thrust
	remaining_thrust = p_remaining_thrust
	charging = p_charging
	grounded = p_grounded
	moving = p_moving
	facing_direction = p_facing_direction
	selected_shot_slot = p_selected_shot_slot
	can_control = p_can_control
	can_fire = p_can_fire
