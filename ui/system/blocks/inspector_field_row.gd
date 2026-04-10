@tool
class_name InspectorFieldRow
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR:
	set(value):
		scope = value
		_apply_scope()

var _label: Label
var _content_root: HBoxContainer
var _label_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _label == null:
		_label = AppLabelScript.new()
		_label.scope = scope
		_label.role = "label"
		_label.custom_minimum_size = Vector2(148.0, 0.0)
		add_child(_label)
	if _content_root == null:
		_content_root = HBoxContainer.new()
		_content_root.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(_content_root)
	_label.text = _label_text
	_apply_scope()

func set_label_text(text: String) -> void:
	_label_text = text
	_ensure_ui()

func get_content_root() -> HBoxContainer:
	_ensure_ui()
	return _content_root

func _apply_scope() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	if _label != null:
		_label.scope = scope
