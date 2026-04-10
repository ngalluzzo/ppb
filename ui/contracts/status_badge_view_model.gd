class_name StatusBadgeViewModel
extends RefCounted

const StatusViewStateScript = preload("res://mobile/status/status_view_state.gd")

var display_name: String = ""
var short_label: String = ""
var icon: Texture2D
var tint: Color = Color.WHITE
var remaining_turns: int = 0
var stacks: int = 1
var tooltip_text: String = ""
var polarity: int = 0
var priority: int = 0
var description: String = ""

static func from_status_view_state(view_state) -> StatusBadgeViewModel:
	var model := StatusBadgeViewModel.new()
	if view_state == null:
		return model
	model.display_name = view_state.display_name
	model.short_label = view_state.short_label
	model.icon = view_state.icon
	model.tint = view_state.tint
	model.remaining_turns = view_state.remaining_turns
	model.stacks = view_state.stacks
	model.polarity = view_state.polarity
	model.priority = view_state.priority
	model.description = view_state.description
	model.tooltip_text = view_state.get_tooltip_text() if view_state.has_method("get_tooltip_text") else ""
	return model

func to_status_view_state() -> StatusViewState:
	return StatusViewStateScript.new(
		display_name,
		short_label,
		icon,
		tint,
		polarity,
		priority,
		remaining_turns,
		stacks,
		description
	)
