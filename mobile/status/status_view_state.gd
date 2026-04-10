class_name StatusViewState
extends RefCounted

var display_name: String = ""
var short_label: String = ""
var icon: Texture2D
var tint: Color = Color.WHITE
var polarity: int = 0
var priority: int = 0
var remaining_turns: int = 0
var stacks: int = 1
var description: String = ""

func _init(
	p_display_name: String = "",
	p_short_label: String = "",
	p_icon: Texture2D = null,
	p_tint: Color = Color.WHITE,
	p_polarity: int = 0,
	p_priority: int = 0,
	p_remaining_turns: int = 0,
	p_stacks: int = 1,
	p_description: String = ""
) -> void:
	display_name = p_display_name
	short_label = p_short_label
	icon = p_icon
	tint = p_tint
	polarity = p_polarity
	priority = p_priority
	remaining_turns = p_remaining_turns
	stacks = p_stacks
	description = p_description

func get_tooltip_text() -> String:
	var parts: Array[String] = [display_name]
	if description.strip_edges() != "":
		parts.append(description.strip_edges())
	parts.append("Turns: %d" % remaining_turns)
	if stacks > 1:
		parts.append("Stacks: %d" % stacks)
	return "\n".join(parts)
