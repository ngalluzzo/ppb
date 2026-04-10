class_name Team
extends RefCounted

enum ControlSourceKind {
	HUMAN,
	AI
}

var team_index: int = 0
var team_name: String = ""
var mobiles: Array[MobileDefinition] = []
var control_source_kind: int = ControlSourceKind.HUMAN

func _init(
	index: int,
	name: String,
	mobile_defs: Array[MobileDefinition],
	p_control_source_kind: int = ControlSourceKind.HUMAN
) -> void:
	team_index = index
	team_name = name
	mobiles = mobile_defs
	control_source_kind = p_control_source_kind
	
