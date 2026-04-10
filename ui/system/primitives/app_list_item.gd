@tool
class_name AppListItem
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _title_label: Label
var _subtitle_label: Label

func _ready() -> void:
	super._ready()
	if _title_label == null:
		var root := VBoxContainer.new()
		add_child(root)
		_title_label = AppLabelScript.new()
		_title_label.scope = scope
		_title_label.role = "label"
		root.add_child(_title_label)
		_subtitle_label = AppLabelScript.new()
		_subtitle_label.scope = scope
		_subtitle_label.role = "caption"
		_subtitle_label.text_role = "muted"
		root.add_child(_subtitle_label)

func set_content(title: String, subtitle: String = "") -> void:
	_ready()
	_title_label.text = title
	_subtitle_label.text = subtitle
	_subtitle_label.visible = subtitle != ""
