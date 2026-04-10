@tool
class_name ApplyResetReplayBar
extends "res://ui/system/blocks/apply_reset_bar.gd"

const DirtyStateChipScript = preload("res://ui/system/blocks/dirty_state_chip.gd")

var _state_chip: DirtyStateChip

func _ready() -> void:
	super._ready()
	if _state_chip == null:
		_state_chip = DirtyStateChipScript.new()
		_state_chip.scope = scope
		add_child(_state_chip)

func set_dirty_state(state: StringName) -> void:
	_ready()
	_state_chip.set_state(state)

