@tool
class_name AppTextField
extends LineEdit

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	add_theme_stylebox_override("normal", AppUIScript.make_field_style(false, scope))
	add_theme_stylebox_override("focus", AppUIScript.make_field_style(true, scope))
	add_theme_stylebox_override("read_only", AppUIScript.make_field_style(false, scope))
