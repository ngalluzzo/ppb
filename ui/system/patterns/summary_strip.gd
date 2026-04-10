@tool
class_name SummaryStrip
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"md", scope))

func set_parts(parts: Array) -> void:
	for child in get_children():
		child.queue_free()
	for text in parts:
		var label := AppLabelScript.new()
		label.scope = scope
		label.role = "caption"
		label.text_role = "muted"
		label.text = text
		add_child(label)
