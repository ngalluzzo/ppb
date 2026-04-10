class_name StatusBadgeContainer
extends Control

const StatusBadgeViewScene = preload("res://ui/status_badge_view.tscn")
const StatusViewSortScript = preload("res://ui/status_view_sort.gd")

@onready var row: HBoxContainer = $Row

@export var active_badge_limit: int = 3
@export var inactive_badge_limit: int = 2

var _mobile: Mobile
var _controller: MobileController

func setup(mobile: Mobile) -> void:
	_mobile = mobile
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _mobile != null and not _mobile.status_view_states_changed.is_connected(_on_mobile_statuses_changed):
		_mobile.status_view_states_changed.connect(_on_mobile_statuses_changed)
	_update_position()
	refresh()

func bind_controller(controller: MobileController) -> void:
	_controller = controller
	if _controller == null:
		return
	if not _controller.activated.is_connected(_on_controller_state_changed):
		_controller.activated.connect(_on_controller_state_changed)
	if not _controller.deactivated.is_connected(_on_controller_state_changed):
		_controller.deactivated.connect(_on_controller_state_changed)
	refresh()

func refresh() -> void:
	for child in row.get_children():
		child.queue_free()
	if _mobile == null:
		visible = false
		return
	var view_states: Array = StatusViewSortScript.sorted(_mobile.get_status_view_states())
	if view_states.is_empty():
		visible = false
		return
	visible = true
	var limit := active_badge_limit if _controller != null and _controller.is_active() else inactive_badge_limit
	for index in range(mini(limit, view_states.size())):
		var badge = StatusBadgeViewScene.instantiate()
		badge.configure(view_states[index], Vector2(28, 28))
		row.add_child(badge)
	call_deferred("_center_row")

func _update_position() -> void:
	if _mobile == null or _mobile.mobile_def == null:
		return
	position = Vector2(0.0, -_mobile.mobile_def.body_size.y * 0.9 - 18.0)

func _center_row() -> void:
	if row == null:
		return
	row.position = Vector2(-row.size.x * 0.5, 0.0)

func _on_controller_state_changed(_controller_ref: MobileController) -> void:
	refresh()

func _on_mobile_statuses_changed(_view_states: Array) -> void:
	refresh()
