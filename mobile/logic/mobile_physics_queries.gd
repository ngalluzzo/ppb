class_name MobilePhysicsQueries
extends RefCounted

var _test_move_callable: Callable
var _safe_margin: float = 0.08

func _init(test_move_callable: Callable = Callable(), safe_margin: float = 0.08) -> void:
	_test_move_callable = test_move_callable
	_safe_margin = safe_margin

func can_occupy(transform: Transform2D) -> bool:
	return not _test(transform, Vector2.ZERO)

func can_move(transform: Transform2D, motion: Vector2) -> bool:
	return not _test(transform, motion)

func get_collision(transform: Transform2D, motion: Vector2) -> KinematicCollision2D:
	var collision := KinematicCollision2D.new()
	if not _test(transform, motion, collision):
		return null
	return collision

func _test(
	transform: Transform2D,
	motion: Vector2,
	collision: KinematicCollision2D = null
) -> bool:
	if not _test_move_callable.is_valid():
		return false
	return _test_move_callable.call(transform, motion, collision, _safe_margin, true)
