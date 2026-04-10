class_name ActionItemView
extends RefCounted

var id: StringName = StringName()
var label: String = ""
var description: String = ""
var icon: Texture2D
var tone: StringName = &"secondary"
var enabled: bool = true
var selected: bool = false
var hotkey_hint: String = ""

func _init(
	p_id: StringName = StringName(),
	p_label: String = "",
	p_description: String = "",
	p_icon: Texture2D = null,
	p_tone: StringName = &"secondary",
	p_enabled: bool = true,
	p_selected: bool = false,
	p_hotkey_hint: String = ""
) -> void:
	id = p_id
	label = p_label
	description = p_description
	icon = p_icon
	tone = p_tone
	enabled = p_enabled
	selected = p_selected
	hotkey_hint = p_hotkey_hint
