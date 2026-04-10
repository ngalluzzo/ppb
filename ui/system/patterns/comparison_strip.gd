@tool
class_name ComparisonStrip
extends HBoxContainer

const AppPanelScript = preload("res://ui/system/primitives/app_panel.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

func configure(left_title: String, left_value: String, right_title: String, right_value: String) -> void:
	for child in get_children():
		child.queue_free()
	_add_side(left_title, left_value)
	_add_side(right_title, right_value)

func _add_side(title: String, value: String) -> void:
	var panel := AppPanelScript.new()
	panel.scope = scope
	panel.variant = "inset"
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var label := AppLabelScript.new()
	label.scope = scope
	label.role = "caption"
	label.text_role = "muted"
	label.text = title
	box.add_child(label)
	var val := AppLabelScript.new()
	val.scope = scope
	val.role = "section"
	val.text = value
	box.add_child(val)

