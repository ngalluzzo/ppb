class_name StatusViewSort
extends RefCounted

const StatusDefinitionScript = preload("res://mobile/status/status_definition.gd")

static func sorted(states: Array) -> Array:
	var ordered := states.duplicate()
	ordered.sort_custom(_compare_status_view_states)
	return ordered

static func _compare_status_view_states(a, b) -> bool:
	var a_rank := _polarity_rank(a.polarity)
	var b_rank := _polarity_rank(b.polarity)
	if a_rank != b_rank:
		return a_rank < b_rank
	if a.priority != b.priority:
		return a.priority > b.priority
	if a.remaining_turns != b.remaining_turns:
		return a.remaining_turns < b.remaining_turns
	return a.display_name.naturalnocasecmp_to(b.display_name) < 0

static func _polarity_rank(polarity: int) -> int:
	match polarity:
		StatusDefinitionScript.Polarity.DEBUFF:
			return 0
		StatusDefinitionScript.Polarity.BUFF:
			return 1
		_:
			return 2

