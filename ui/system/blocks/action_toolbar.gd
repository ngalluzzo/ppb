@tool
class_name ActionToolbar
extends "res://ui/system/patterns/action_cluster.gd"

const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")

signal action_pressed(id: StringName)

func set_actions(actions: Array) -> void:
	for child in get_children():
		child.queue_free()
	for action in actions:
		var button := AppButtonScript.new()
		button.scope = scope
		button.variant = _tone_to_variant(action.tone if action != null else &"secondary")
		button.text = str(action.label if action != null else "")
		button.disabled = not bool(action.enabled if action != null else true)
		if action != null and str(action.description) != "":
			button.tooltip_text = str(action.description)
		if action != null:
			var action_id: StringName = action.id
			button.pressed.connect(func() -> void:
				action_pressed.emit(action_id)
			)
		add_child(button)

func _tone_to_variant(tone: StringName) -> int:
	match tone:
		&"primary":
			return AppButtonScript.Variant.PRIMARY
		&"danger":
			return AppButtonScript.Variant.DANGER
		&"ghost":
			return AppButtonScript.Variant.GHOST
		_:
			return AppButtonScript.Variant.SECONDARY
