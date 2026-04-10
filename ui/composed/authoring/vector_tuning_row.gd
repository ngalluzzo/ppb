@tool
class_name VectorTuningRow
extends VBoxContainer

const LabelControlRowScript = preload("res://ui/system/patterns/label_control_row.gd")
const AppSpinFieldScript = preload("res://ui/system/primitives/app_spin_field.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _row: LabelControlRow
var _x_spin: SpinBox
var _y_spin: SpinBox

func _ready() -> void:
	if _row != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))
	_row = LabelControlRowScript.new()
	_row.scope = scope
	add_child(_row)
	_x_spin = AppSpinFieldScript.new()
	_x_spin.scope = scope
	_x_spin.prefix = "X "
	_x_spin.size_flags_horizontal = SIZE_EXPAND_FILL
	_row.get_content_root().add_child(_x_spin)
	_y_spin = AppSpinFieldScript.new()
	_y_spin.scope = scope
	_y_spin.prefix = "Y "
	_y_spin.size_flags_horizontal = SIZE_EXPAND_FILL
	_row.get_content_root().add_child(_y_spin)

func set_label_text(text: String) -> void:
	_ready()
	_row.set_label_text(text)

func get_x_spin_box() -> SpinBox:
	_ready()
	return _x_spin

func get_y_spin_box() -> SpinBox:
	_ready()
	return _y_spin

