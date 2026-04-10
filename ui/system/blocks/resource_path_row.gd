@tool
class_name ResourcePathRow
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR:
	set(value):
		scope = value
		_apply_scope()

var _label: Label
var _value: Label
var _label_text: String = ""
var _value_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _label == null:
		_label = AppLabelScript.new()
		_label.scope = scope
		_label.role = "caption"
		_label.text_role = "muted"
		_label.custom_minimum_size = Vector2(112.0, 0.0)
		add_child(_label)
	if _value == null:
		_value = AppLabelScript.new()
		_value.scope = scope
		_value.role = "caption"
		_value.text_role = "muted"
		_value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_value.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(_value)
	_label.text = _label_text
	_value.text = _value_text
	_apply_scope()

func set_label_text(text: String) -> void:
	_label_text = text
	_ensure_ui()

func set_value_text(text: String) -> void:
	_value_text = text
	_ensure_ui()

func _apply_scope() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	if _label != null:
		_label.scope = scope
	if _value != null:
		_value.scope = scope
