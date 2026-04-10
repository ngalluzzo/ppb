@tool
class_name DirtyStateChip
extends "res://ui/system/primitives/app_badge.gd"

func set_state(state: StringName) -> void:
	var label := ""
	match state:
		&"dirty":
			variant = "warning"
			label = "Preview Modified"
		&"applied":
			variant = "success"
			label = "Applied"
		&"reloaded":
			variant = "info"
			label = "Disk Reloaded"
		_:
			variant = "neutral"
			label = "Clean"
	text_value = label
