@tool
class_name AppSegmentedControl
extends HBoxContainer

const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

signal item_selected(index: int)

@export var scope: int = AppUIScript.Scope.RUNTIME

var _labels: Array[String] = []
var _selected_index: int = 0

func set_items(labels: Array[String], selected_index: int = 0) -> void:
	_labels = labels.duplicate()
	_selected_index = selected_index
	_rebuild()

func select(index: int) -> void:
	_selected_index = clampi(index, 0, maxi(_labels.size() - 1, 0))
	_rebuild()

func _ready() -> void:
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	for index in _labels.size():
		var button := AppButtonScript.new()
		button.scope = scope
		button.variant = AppButtonScript.Variant.PRIMARY if index == _selected_index else AppButtonScript.Variant.GHOST
		button.text = _labels[index]
		button.pressed.connect(func(selected := index):
			_selected_index = selected
			_rebuild()
			item_selected.emit(selected)
		)
		add_child(button)
