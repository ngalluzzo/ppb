@tool
class_name SectionStack
extends VBoxContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_spacing()

@export var compact: bool = false:
	set(value):
		compact = value
		_apply_spacing()

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	_apply_spacing()

func _apply_spacing() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope) if compact else AppUIScript.spacing(&"md", scope))

