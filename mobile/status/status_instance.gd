class_name StatusInstance
extends RefCounted

var definition: Resource
var remaining_turns: int = 0
var stacks: int = 1
var source_kind: StringName = &""
var source_id: String = ""
var team_index: int = -1
var applier_id: String = ""
var runtime_modifiers: Array[StatModifier] = []

func _init(
	p_definition: Resource = null,
	p_remaining_turns: int = 0,
	p_stacks: int = 1,
	p_source_kind: StringName = &"",
	p_source_id: String = "",
	p_team_index: int = -1,
	p_applier_id: String = ""
) -> void:
	definition = p_definition
	remaining_turns = p_remaining_turns
	stacks = maxi(1, p_stacks)
	source_kind = p_source_kind
	source_id = p_source_id
	team_index = p_team_index
	applier_id = p_applier_id

func has_tag(tag: String) -> bool:
	return definition != null and definition.tags.has(tag)
