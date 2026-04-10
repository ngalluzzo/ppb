@tool
class_name NumericTuningRow
extends "res://ui/system/patterns/label_control_row.gd"

const AppSpinFieldScript = preload("res://ui/system/primitives/app_spin_field.gd")
const AppUnitLabelScript = preload("res://ui/system/primitives/app_label.gd")

var _spin: SpinBox
var _unit_label: AppLabel

func _ready() -> void:
	super._ready()
	if _spin != null:
		return
	_spin = AppSpinFieldScript.new()
	_spin.scope = scope
	_spin.size_flags_horizontal = SIZE_EXPAND_FILL
	get_content_root().add_child(_spin)
	_unit_label = AppUnitLabelScript.new()
	_unit_label.scope = scope
	_unit_label.role = "caption"
	_unit_label.text_role = "muted"
	get_content_root().add_child(_unit_label)

func get_spin_box() -> SpinBox:
	_ready()
	return _spin

func set_unit_text(text: String) -> void:
	_ready()
	_unit_label.text = text
	_unit_label.visible = text != ""
