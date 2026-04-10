@tool
class_name PowerAngleMeter
extends VBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppProgressBarScript = preload("res://ui/system/primitives/app_progress_bar.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _angle_label: AppLabel
var _power_bar: Range
var _power_label: AppLabel

func _ready() -> void:
	if _angle_label != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))
	_angle_label = AppLabelScript.new()
	_angle_label.scope = scope
	_angle_label.role = "section"
	add_child(_angle_label)
	_power_bar = AppProgressBarScript.new()
	_power_bar.scope = scope
	_power_bar.custom_minimum_size = Vector2(200, AppUIScript.control_height(&"default", scope))
	add_child(_power_bar)
	_power_label = AppLabelScript.new()
	_power_label.scope = scope
	_power_label.role = "caption"
	_power_label.text_role = "muted"
	add_child(_power_label)

func set_values(angle: float, power: float, max_power: float) -> void:
	_ready()
	_angle_label.text = "Angle %.0f°" % angle
	_power_bar.max_value = maxf(max_power, 1.0)
	_power_bar.value = power
	_power_label.text = "Power %.0f / %.0f" % [power, max_power]

