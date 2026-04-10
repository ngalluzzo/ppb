@tool
class_name AppDivider
extends Control

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 1.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	draw_line(Vector2(0.0, size.y * 0.5), Vector2(size.x, size.y * 0.5), AppUIScript.color(&"soft", scope), 1.0)
