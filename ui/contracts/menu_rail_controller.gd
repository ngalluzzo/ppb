class_name MenuRailController
extends RefCounted

signal activated(id: StringName)

var selection_model: SelectionModel = SelectionModel.new()
var focus_controller: FocusableListController = FocusableListController.new()

func activate(action: ActionItemView) -> void:
	if action == null or not action.enabled:
		return
	selection_model.set_selected(action.id)
	activated.emit(action.id)
