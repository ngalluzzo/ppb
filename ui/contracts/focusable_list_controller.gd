class_name FocusableListController
extends RefCounted

var focus_index: int = -1

func move(delta: int, count: int) -> int:
	if count <= 0:
		focus_index = -1
		return focus_index
	if focus_index < 0:
		focus_index = 0
	else:
		focus_index = posmod(focus_index + delta, count)
	return focus_index
