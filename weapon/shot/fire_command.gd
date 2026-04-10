class_name FireCommand
extends RefCounted

var shooter_id: String = ""
var shot_slot: StringName = &"shot_1"
var requested_angle_degrees: float = 0.0
var requested_power: float = 0.0
var local_frame: int = 0

func _init(
	p_shooter_id: String = "",
	p_shot_slot: StringName = &"shot_1",
	p_requested_angle_degrees: float = 0.0,
	p_requested_power: float = 0.0,
	p_local_frame: int = 0
) -> void:
	shooter_id = p_shooter_id
	shot_slot = p_shot_slot
	requested_angle_degrees = p_requested_angle_degrees
	requested_power = p_requested_power
	local_frame = p_local_frame

func to_dict() -> Dictionary:
	return {
		"shooter_id": shooter_id,
		"shot_slot": String(shot_slot),
		"requested_angle_degrees": requested_angle_degrees,
		"requested_power": requested_power,
		"local_frame": local_frame,
	}

static func from_dict(data: Dictionary) -> FireCommand:
	return FireCommand.new(
		data.get("shooter_id", ""),
		StringName(data.get("shot_slot", "shot_1")),
		float(data.get("requested_angle_degrees", 0.0)),
		float(data.get("requested_power", 0.0)),
		int(data.get("local_frame", 0))
	)
