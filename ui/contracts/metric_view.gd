class_name MetricView
extends RefCounted

var label: String = ""
var value: String = ""
var hint: String = ""
var tone: StringName = &"primary"

func _init(p_label: String = "", p_value: String = "", p_hint: String = "", p_tone: StringName = &"primary") -> void:
	label = p_label
	value = p_value
	hint = p_hint
	tone = p_tone
