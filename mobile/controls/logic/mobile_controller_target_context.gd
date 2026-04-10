class_name MobileControllerTargetContext
extends RefCounted

var team_index: int = -1
var combatant_id: String = ""
var mobile
var follow_target

func _init(
	p_team_index: int = -1,
	p_combatant_id: String = "",
	p_mobile = null,
	p_follow_target = null
) -> void:
	team_index = p_team_index
	combatant_id = p_combatant_id
	mobile = p_mobile
	follow_target = p_follow_target
