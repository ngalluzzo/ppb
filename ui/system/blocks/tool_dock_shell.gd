@tool
class_name ToolDockShell
extends VBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppDividerScript = preload("res://ui/system/primitives/app_divider.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _title_label: Label
var _help_label: Label
var _content_root: VBoxContainer
var _title_text: String = ""
var _help_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	size_flags_horizontal = SIZE_EXPAND_FILL
	AppUIScript.apply_theme(self, scope)

	if _title_label == null:
		_title_label = AppLabelScript.new()
		_title_label.scope = scope
		_title_label.role = "title"
		add_child(_title_label)
	if _help_label == null:
		_help_label = AppLabelScript.new()
		_help_label.scope = scope
		_help_label.role = "body"
		_help_label.text_role = "muted"
		_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(_help_label)
	if _content_root == null:
		var divider := AppDividerScript.new()
		divider.scope = scope
		add_child(divider)
		_content_root = VBoxContainer.new()
		_content_root.size_flags_vertical = SIZE_EXPAND_FILL
		_content_root.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(_content_root)
	_title_label.text = _title_text
	_help_label.text = _help_text
	_help_label.visible = _help_text != ""

func set_title_text(text: String) -> void:
	_title_text = text
	_ensure_ui()

func set_help_text(text: String) -> void:
	_help_text = text
	_ensure_ui()

func get_content_root() -> VBoxContainer:
	_ensure_ui()
	return _content_root
