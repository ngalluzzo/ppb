class_name ToolbarCommandMap
extends RefCounted

var _commands: Dictionary = {}

func register(action_id: StringName, callback: Callable) -> void:
	_commands[String(action_id)] = callback

func trigger(action_id: StringName) -> bool:
	var key := String(action_id)
	if not _commands.has(key):
		return false
	var callback: Callable = _commands[key]
	if callback.is_valid():
		callback.call()
		return true
	return false
