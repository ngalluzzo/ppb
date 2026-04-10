@tool
class_name TurnHeader
extends "res://ui/system/primitives/app_panel.gd"

const LabelValueTableScript = preload("res://ui/composed/shared/label_value_table.gd")

var _table: LabelValueTable

func _ready() -> void:
	super._ready()
	if _table != null:
		return
	_table = LabelValueTableScript.new()
	_table.scope = scope
	add_child(_table)

func set_turn_info(combatant_name: String, phase_name: String, timer_text: String) -> void:
	_ready()
	_table.set_rows([
		{"label": "Turn", "value": combatant_name},
		{"label": "Phase", "value": phase_name},
		{"label": "Timer", "value": timer_text},
	])

