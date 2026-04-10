@tool
class_name FireControlCluster
extends VBoxContainer

const PowerAngleMeterScript = preload("res://ui/composed/battle/power_angle_meter.gd")
const ShotSlotBarScript = preload("res://ui/composed/battle/shot_slot_bar.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

signal shot_slot_selected(index: int)

@export var scope: int = AppUIScript.Scope.RUNTIME

var _meter: PowerAngleMeter
var _slots: ShotSlotBar

func _ready() -> void:
	if _meter != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_meter = PowerAngleMeterScript.new()
	_meter.scope = scope
	add_child(_meter)
	_slots = ShotSlotBarScript.new()
	_slots.scope = scope
	_slots.item_selected.connect(shot_slot_selected.emit)
	add_child(_slots)

func set_control_state(state: MobileControlState) -> void:
	_ready()
	if state == null:
		_meter.set_values(0.0, 0.0, 1.0)
		_slots.select_slot(&"shot_1")
		return
	_meter.set_values(state.current_angle, state.current_power, state.max_power)
	_slots.select_slot(state.selected_shot_slot)

