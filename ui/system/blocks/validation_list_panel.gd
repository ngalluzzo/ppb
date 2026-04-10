@tool
class_name ValidationListPanel
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _title_label: Label
var _summary_label: Label
var _list: ItemList
var _title_text: String = ""
var _summary_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	super._ready()
	if _title_label == null:
		var root := VBoxContainer.new()
		root.size_flags_vertical = SIZE_EXPAND_FILL
		root.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(root)

		_title_label = AppLabelScript.new()
		_title_label.scope = scope
		_title_label.role = "section"
		root.add_child(_title_label)

		_summary_label = AppLabelScript.new()
		_summary_label.scope = scope
		_summary_label.role = "caption"
		_summary_label.text_role = "muted"
		root.add_child(_summary_label)

		_list = ItemList.new()
		_list.size_flags_vertical = SIZE_EXPAND_FILL
		root.add_child(_list)
	_title_label.text = _title_text
	_summary_label.text = _summary_text

func set_title_text(text: String) -> void:
	_title_text = text
	_ensure_ui()

func set_summary_text(text: String) -> void:
	_summary_text = text
	_ensure_ui()

func get_list() -> ItemList:
	_ensure_ui()
	return _list
