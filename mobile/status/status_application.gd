class_name StatusApplication
extends RefCounted

const StatusDefinitionScript = preload("res://mobile/status/status_definition.gd")
const ResourceValidationScript = preload("res://shared/resource_validation.gd")

var status_definition: Resource
var source_kind: StringName = &""
var source_id: String = ""
var duration_turns: int = 0
var stacks: int = 1
var team_index: int = -1
var applier_id: String = ""
var target_mobile

func _init(
	p_status_definition: Resource = null,
	p_source_kind: StringName = &"",
	p_source_id: String = "",
	p_duration_turns: int = 0,
	p_stacks: int = 1,
	p_team_index: int = -1,
	p_applier_id: String = "",
	p_target_mobile = null
) -> void:
	status_definition = ResourceValidationScript.require_resource(
		p_status_definition,
		StatusDefinitionScript,
		"StatusDefinition",
		"StatusApplication.status_definition"
	)
	source_kind = p_source_kind
	source_id = p_source_id
	duration_turns = p_duration_turns
	stacks = maxi(1, p_stacks)
	team_index = p_team_index
	applier_id = p_applier_id
	target_mobile = p_target_mobile
