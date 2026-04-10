@tool
class_name ModalActionSheet
extends "res://ui/system/primitives/app_panel.gd"

const PrimaryActionMenuScript = preload("res://ui/composed/title/primary_action_menu.gd")

var _menu: PrimaryActionMenu

func _ready() -> void:
	super._ready()
	if _menu != null:
		return
	_menu = PrimaryActionMenuScript.new()
	_menu.scope = scope
	add_child(_menu)

func get_menu() -> PrimaryActionMenu:
	_ready()
	return _menu

