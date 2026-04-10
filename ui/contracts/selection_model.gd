class_name SelectionModel
extends RefCounted

signal changed(selection: Array[StringName])

var selected_ids: Array[StringName] = []
var allows_multiple: bool = false

func set_selected(id: StringName) -> void:
	selected_ids = [id]
	changed.emit(selected_ids)

func toggle(id: StringName) -> void:
	if allows_multiple:
		if selected_ids.has(id):
			selected_ids.erase(id)
		else:
			selected_ids.append(id)
	else:
		selected_ids = [] if selected_ids.has(id) else [id]
	changed.emit(selected_ids)

func is_selected(id: StringName) -> bool:
	return selected_ids.has(id)
