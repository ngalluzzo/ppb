@tool
class_name MobileCard
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const RoleTagStripScript = preload("res://ui/composed/roster/role_tag_strip.gd")

var _title: AppLabel
var _subtitle: AppLabel
var _tags: RoleTagStrip

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
	_subtitle = AppLabelScript.new()
	_subtitle.scope = scope
	_subtitle.role = "caption"
	_subtitle.text_role = "muted"
	box.add_child(_subtitle)
	_tags = RoleTagStripScript.new()
	_tags.scope = scope
	box.add_child(_tags)

func configure(name_text: String, subtitle_text: String, tags: Array[String]) -> void:
	_ready()
	_title.text = name_text
	_subtitle.text = subtitle_text
	_tags.set_tags(tags)

