@tool
class_name PreviewTransport
extends HBoxContainer

const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

signal replay_pressed
signal reset_pressed
signal pause_pressed

@export var scope: int = AppUIScript.Scope.EDITOR

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_add_button("Replay", AppButtonScript.Variant.PRIMARY, replay_pressed.emit)
	_add_button("Start", AppButtonScript.Variant.SECONDARY, reset_pressed.emit)
	_add_button("Pause", AppButtonScript.Variant.GHOST, pause_pressed.emit)

func _add_button(text: String, variant: int, callback: Callable) -> void:
	var button := AppButtonScript.new()
	button.scope = scope
	button.variant = variant
	button.text = text
	button.pressed.connect(callback)
	add_child(button)

