@tool
class_name ActiveShotSummary
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _title: AppLabel
var _detail: AppLabel

func _ready() -> void:
	super._ready()
	if _title != null:
		return
	var box := VBoxContainer.new()
	add_child(box)
	_title = AppLabelScript.new()
	_title.scope = scope
	_title.role = "section"
	box.add_child(_title)
	_detail = AppLabelScript.new()
	_detail.scope = scope
	_detail.role = "caption"
	_detail.text_role = "muted"
	box.add_child(_detail)

func set_summary(title: String, detail: String) -> void:
	_ready()
	_title.text = title
	_detail.text = detail

