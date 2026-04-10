@tool
class_name ShotSlotBar
extends "res://ui/system/primitives/app_segmented_control.gd"

func _ready() -> void:
	super._ready()
	set_items(["Shot 1", "Shot 2", "SS"], _selected_index)

func select_slot(slot: StringName) -> void:
	match slot:
		&"shot_2":
			select(1)
		&"shot_ss":
			select(2)
		_:
			select(0)

