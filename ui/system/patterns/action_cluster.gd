@tool
class_name ActionCluster
extends HBoxContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

