@tool
class_name AppTooltipAnchor
extends Control

@export_multiline var text_value: String = "":
	set(value):
		text_value = value
		tooltip_text = value

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip_text = text_value
