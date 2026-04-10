@tool
class_name StatusBadgeStack
extends ScrollContainer

const StatusBadgeViewScene = preload("res://ui/status_badge_view.tscn")
const StatusBadgeViewModelScript = preload("res://ui/contracts/status_badge_view_model.gd")

var _row: HBoxContainer

func _ready() -> void:
	if _row != null:
		return
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_row = HBoxContainer.new()
	_row.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_row)

func set_view_models(models: Array) -> void:
	_ready()
	for child in _row.get_children():
		child.queue_free()
	for model in models:
		var badge := StatusBadgeViewScene.instantiate()
		if model is StatusBadgeViewModel:
			badge.configure(model.to_status_view_state(), Vector2(34, 34))
		elif model != null:
			badge.configure(model, Vector2(34, 34))
		_row.add_child(badge)
	visible = _row.get_child_count() > 0
