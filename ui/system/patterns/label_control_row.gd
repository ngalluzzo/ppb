@tool
class_name LabelControlRow
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _label_node: AppLabel
var _control_root: HBoxContainer

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
	_label_node.custom_minimum_size = Vector2(120, 0)
	add_child(_label_node)
	_control_root = HBoxContainer.new()
	_control_root.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_control_root)

func set_label_text(text: String) -> void:
	_ensure_ui()
	_label_node.text = text

func get_content_root() -> HBoxContainer:
	_ensure_ui()
	return _control_root

