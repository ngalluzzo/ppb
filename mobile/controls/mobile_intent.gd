class_name MobileIntent
extends RefCounted

var aim_delta: float
var move_direction: int
var begin_charge: bool
var continue_charge: bool
var release_fire: bool
var selected_shot_slot: StringName

func _init(
	p_aim_delta: float = 0.0,
	p_move_direction: int = 0,
	p_begin_charge: bool = false,
	p_continue_charge: bool = false,
	p_release_fire: bool = false,
	p_selected_shot_slot: StringName = &"shot_1"
) -> void:
	aim_delta = p_aim_delta
	move_direction = clampi(p_move_direction, -1, 1)
	begin_charge = p_begin_charge
	continue_charge = p_continue_charge
	release_fire = p_release_fire
	selected_shot_slot = p_selected_shot_slot

static func idle(p_selected_shot_slot: StringName = &"shot_1") -> MobileIntent:
	return MobileIntent.new(0.0, 0, false, false, false, p_selected_shot_slot)
