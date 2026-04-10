@tool
class_name ShotIdentityCard
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
	_detail.role = "body"
	_detail.text_role = "muted"
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_detail)

func set_view(view: ShotIdentityView) -> void:
	_ready()
	if view == null:
		_title.text = "Shot"
		_detail.text = ""
		return
	_title.text = view.name
	_detail.text = view.summary

