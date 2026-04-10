@tool
class_name AppMeter
extends Control

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME
@export var ratio: float = 0.0:
	set(value):
		ratio = clampf(value, 0.0, 1.0)
		queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(100.0, AppUIScript.control_height(&"compact", scope))

func _draw() -> void:
	var bg := Rect2(Vector2.ZERO, size)
	draw_rect(bg, AppUIScript.color(&"inset", scope), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)), AppUIScript.color(&"interactive", scope), true)
