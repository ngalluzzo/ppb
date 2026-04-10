@tool
class_name CombatantStatusPanel
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const StatusBadgeStackScript = preload("res://ui/composed/battle/status_badge_stack.gd")
const LabelValueTableScript = preload("res://ui/composed/shared/label_value_table.gd")

var _title: AppLabel
var _table: LabelValueTable
var _badges: StatusBadgeStack

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
	_table = LabelValueTableScript.new()
	_table.scope = scope
	box.add_child(_table)
	_badges = StatusBadgeStackScript.new()
	box.add_child(_badges)

func set_view(view) -> void:
	_ready()
	if view == null:
		_title.text = "No Active Unit"
		_table.set_rows([])
		_badges.set_view_models([])
		return
	_title.text = str(view.display_name)
	_table.set_rows([
		{"label": "Angle", "value": str(view.angle_text)},
		{"label": "Shot", "value": str(view.shot_slot_text)},
		{"label": "Power", "value": str(view.power_text)},
		{"label": "Thrust", "value": str(view.thrust_text)},
	])
	_badges.set_view_models(view.status_badges)
