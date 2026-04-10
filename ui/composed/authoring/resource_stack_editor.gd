@tool
class_name ResourceStackEditor
extends ScrollContainer

var _stack: VBoxContainer

func _ready() -> void:
	if _stack != null:
		return
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	_stack = VBoxContainer.new()
	_stack.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_stack)

func get_stack_root() -> VBoxContainer:
	_ready()
	return _stack

