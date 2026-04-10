@tool
extends EditorPlugin

const ShotDesignerDockScript = preload("res://addons/shot_designer/shot_designer_dock.gd")

var _dock: VBoxContainer

func _enter_tree() -> void:
	_dock = ShotDesignerDockScript.new()
	_dock.plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)

func _exit_tree() -> void:
	if _dock == null:
		return
	remove_control_from_docks(_dock)
	_dock.queue_free()
	_dock = null
