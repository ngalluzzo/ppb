@tool
class_name CardGrid
extends GridContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_spacing()

func _ready() -> void:
	columns = 2
	_apply_spacing()

func _apply_spacing() -> void:
	add_theme_constant_override("h_separation", AppUIScript.spacing(&"sm", scope))
	add_theme_constant_override("v_separation", AppUIScript.spacing(&"sm", scope))

