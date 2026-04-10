@tool
class_name EmptySelectionState
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _title_label: AppLabel
var _detail_label: AppLabel

func _ready() -> void:
	super._ready()
	if _title_label != null:
		return
	var box := VBoxContainer.new()
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(box)
	_title_label = AppLabelScript.new()
	_title_label.scope = scope
	_title_label.role = "section"
	box.add_child(_title_label)
	_detail_label = AppLabelScript.new()
	_detail_label.scope = scope
	_detail_label.role = "body"
	_detail_label.text_role = "muted"
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_detail_label)

func configure(title: String, detail: String) -> void:
	_ready()
	_title_label.text = title
	_detail_label.text = detail

