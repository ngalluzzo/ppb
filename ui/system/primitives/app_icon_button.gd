@tool
class_name AppIconButton
extends "res://ui/system/primitives/app_button.gd"

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_apply_icon()

func _ready() -> void:
	super._ready()
	_apply_icon()

func _apply_icon() -> void:
	if not is_inside_tree():
		return
	icon = icon_texture
