@tool
class_name AppPanel
extends PanelContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

@export_enum("default", "inset", "accent") var variant: String = "default":
	set(value):
		variant = value
		_apply_style()

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	add_theme_stylebox_override("panel", AppUIScript.make_panel_style(StringName(variant), scope))
