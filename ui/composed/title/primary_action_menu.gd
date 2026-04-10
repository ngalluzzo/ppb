@tool
class_name PrimaryActionMenu
extends VBoxContainer

const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const MenuRailControllerScript = preload("res://ui/contracts/menu_rail_controller.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

signal action_pressed(id: StringName)

@export var scope: int = AppUIScript.Scope.RUNTIME

var _actions: Array = []
var _buttons: Array[Button] = []
var _controller := MenuRailControllerScript.new()

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

func set_actions(actions: Array) -> void:
	_actions = actions.duplicate()
	for child in get_children():
		child.queue_free()
	_buttons.clear()
	for action in _actions:
		var button := AppButtonScript.new()
		button.scope = scope
		button.variant = AppButtonScript.Variant.PRIMARY if bool(action.selected) else AppButtonScript.Variant.GHOST
		button.text = str(action.label)
		button.disabled = not bool(action.enabled)
		button.tooltip_text = str(action.description)
		var action_id: StringName = action.id
		button.pressed.connect(func() -> void:
			action_pressed.emit(action_id)
		)
		add_child(button)
		_buttons.append(button)

func activate_selected() -> void:
	for index in _actions.size():
		var action = _actions[index]
		if action != null and bool(action.selected) and bool(action.enabled):
			action_pressed.emit(action.id)
			return
	if not _actions.is_empty():
		var fallback = _actions[0]
		if fallback != null and bool(fallback.enabled):
			action_pressed.emit(fallback.id)

