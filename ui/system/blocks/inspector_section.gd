@tool
class_name InspectorSection
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

@export var compact: bool = false:
	set(value):
		compact = value
		_update_spacing()

var _title_label: Label
var _path_label: Label
var _content_root: VBoxContainer
var _title_text: String = ""
var _path_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	super._ready()
	if _title_label == null:
		var root := VBoxContainer.new()
		root.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(root)

		_title_label = AppLabelScript.new()
		_title_label.scope = scope
		_title_label.role = "section"
		root.add_child(_title_label)

		_path_label = AppLabelScript.new()
		_path_label.scope = scope
		_path_label.role = "caption"
		_path_label.text_role = "muted"
		_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		root.add_child(_path_label)

		_content_root = VBoxContainer.new()
		_content_root.size_flags_horizontal = SIZE_EXPAND_FILL
		root.add_child(_content_root)
	_title_label.text = _title_text
	_path_label.text = _path_text
	_path_label.visible = _path_text != ""
	_update_spacing()

func set_title_text(text: String) -> void:
	_title_text = text
	_ensure_ui()

func set_path_text(text: String) -> void:
	_path_text = text
	_ensure_ui()

func get_content_root() -> VBoxContainer:
	_ensure_ui()
	return _content_root

func _update_spacing() -> void:
	if _content_root != null:
		_content_root.add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope) if compact else AppUIScript.spacing(&"sm", scope))
