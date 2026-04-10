@tool
class_name AppProgressBar
extends ProgressBar

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

func _ready() -> void:
	show_percentage = false
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	var bg := StyleBoxFlat.new()
	bg.bg_color = AppUIScript.color(&"inset", scope)
	bg.corner_radius_top_left = AppUIScript.radius(&"sm", scope)
	bg.corner_radius_top_right = AppUIScript.radius(&"sm", scope)
	bg.corner_radius_bottom_left = AppUIScript.radius(&"sm", scope)
	bg.corner_radius_bottom_right = AppUIScript.radius(&"sm", scope)
	var fill := bg.duplicate()
	fill.bg_color = AppUIScript.color(&"interactive", scope)
	add_theme_stylebox_override("background", bg)
	add_theme_stylebox_override("fill", fill)
	custom_minimum_size.y = AppUIScript.control_height(&"compact", scope)
