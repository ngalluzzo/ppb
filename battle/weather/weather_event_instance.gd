class_name WeatherEventInstance
extends RefCounted

var definition: Resource
var remaining_turns: int = 0
var event_seed: int = 0
var resolved_modifiers: Array[Resource] = []

func _init(
	p_definition: Resource = null,
	p_remaining_turns: int = 0,
	p_seed: int = 0,
	p_resolved_modifiers: Array[Resource] = []
) -> void:
	definition = p_definition
	remaining_turns = p_remaining_turns
	event_seed = p_seed
	resolved_modifiers = p_resolved_modifiers

func copy() -> WeatherEventInstance:
	return WeatherEventInstance.new(
		definition,
		remaining_turns,
		event_seed,
		resolved_modifiers.duplicate()
	)
