@tool
class_name LabelValueRow
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _label_node: AppLabel
var _value_node: AppLabel

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	if _label_node != null:
		return
	_label_node = AppLabelScript.new()
	_label_node.scope = scope
	_label_node.role = "label"
	_label_node.text_role = "muted"
	_label_node.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_label_node)
	_value_node = AppLabelScript.new()
	_value_node.scope = scope
	_value_node.role = "body"
	_value_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_value_node)

func set_label_text(text: String) -> void:
	_ensure_ui()
	_label_node.text = text

func set_value_text(text: String) -> void:
	_ensure_ui()
	_value_node.text = text

func set_value_role(role: StringName) -> void:
	_ensure_ui()
	_value_node.text_role = String(role)
	_value_node.queue_redraw()

