class_name MobileControlSourceSnapshot
extends RefCounted

var combatant_id: String
var team_index: int
var selected_shot_slot: StringName
var current_angle: float
var current_power: float
var min_power: float
var max_power: float
var remaining_thrust: float
var max_thrust: float
var charging: bool
var grounded: bool
var moving: bool
var facing_direction: int
var can_control: bool
var can_fire: bool
var aim_speed: float

func _init(
	p_combatant_id: String = "",
	p_team_index: int = -1,
	p_selected_shot_slot: StringName = &"shot_1",
	p_current_angle: float = 0.0,
	p_current_power: float = 0.0,
	p_min_power: float = 0.0,
	p_max_power: float = 0.0,
	p_remaining_thrust: float = 0.0,
	p_max_thrust: float = 0.0,
	p_charging: bool = false,
	p_grounded: bool = false,
	p_moving: bool = false,
	p_facing_direction: int = 1,
	p_can_control: bool = false,
	p_can_fire: bool = false,
	p_aim_speed: float = 0.0
) -> void:
	combatant_id = p_combatant_id
	team_index = p_team_index
	selected_shot_slot = p_selected_shot_slot
	current_angle = p_current_angle
	current_power = p_current_power
	min_power = p_min_power
	max_power = p_max_power
	remaining_thrust = p_remaining_thrust
	max_thrust = p_max_thrust
	charging = p_charging
	grounded = p_grounded
	moving = p_moving
	facing_direction = p_facing_direction
	can_control = p_can_control
	can_fire = p_can_fire
	aim_speed = p_aim_speed
