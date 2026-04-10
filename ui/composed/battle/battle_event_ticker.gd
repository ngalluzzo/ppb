@tool
class_name BattleEventTicker
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _label: AppLabel

func _ready() -> void:
	super._ready()
	if _label != null:
		return
	_label = AppLabelScript.new()
	_label.scope = scope
	_label.role = "caption"
	_label.text_role = "muted"
	add_child(_label)

func set_events(events: Array[String]) -> void:
	_ready()
	_label.text = " | ".join(events)

