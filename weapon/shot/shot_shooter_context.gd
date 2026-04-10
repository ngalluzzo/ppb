class_name ShotShooterContext
extends RefCounted

var combatant_id: String = ""
var team_index: int = -1
var facing_direction: int = 1

func _init(
	p_combatant_id: String = "",
	p_team_index: int = -1,
	p_facing_direction: int = 1
) -> void:
	combatant_id = p_combatant_id
	team_index = p_team_index
	facing_direction = -1 if p_facing_direction < 0 else 1
