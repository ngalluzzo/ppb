class_name MobilePhysicsAdapter
extends RefCounted

const FloorContactStateScript = preload("res://shared/runtime/floor_contact_state.gd")
const SurfaceContactScript = preload("res://shared/runtime/surface_contact.gd")

var _test_move_callable: Callable
var _move_body_callable: Callable
var _apply_floor_snap_callable: Callable
var _floor_contact_callable: Callable
var _safe_margin: float = 0.08

func _init(
	test_move_callable: Callable = Callable(),
	move_body_callable: Callable = Callable(),
	apply_floor_snap_callable: Callable = Callable(),
	floor_contact_callable: Callable = Callable(),
	safe_margin: float = 0.08
) -> void:
	_test_move_callable = test_move_callable
	_move_body_callable = move_body_callable
	_apply_floor_snap_callable = apply_floor_snap_callable
	_floor_contact_callable = floor_contact_callable
	_safe_margin = safe_margin

func move_body() -> void:
	if _move_body_callable.is_valid():
		_move_body_callable.call()

func apply_floor_snap() -> void:
	if _apply_floor_snap_callable.is_valid():
		_apply_floor_snap_callable.call()

func get_floor_contact_state() -> FloorContactState:
	if not _floor_contact_callable.is_valid():
		return FloorContactStateScript.new()
	var state = _floor_contact_callable.call()
	return state if state != null else FloorContactStateScript.new()

func can_occupy(transform: Transform2D) -> bool:
	return not _test(transform, Vector2.ZERO)

func can_move(transform: Transform2D, motion: Vector2) -> bool:
	return not _test(transform, motion)

func get_surface_contact(transform: Transform2D, motion: Vector2) -> SurfaceContact:
	var collision := KinematicCollision2D.new()
	if not _test(transform, motion, collision):
		return null
	return SurfaceContactScript.new(collision.get_normal(), collision.get_position(), &"body")

func _test(
	transform: Transform2D,
	motion: Vector2,
	collision: KinematicCollision2D = null
) -> bool:
	if not _test_move_callable.is_valid():
		return false
	return _test_move_callable.call(transform, motion, collision, _safe_margin, true)
