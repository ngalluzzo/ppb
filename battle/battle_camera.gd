class_name BattleCamera
extends Camera2D

const BattleViewConfigScript = preload("res://battle/battle_view_config.gd")

var _fallback_anchor: Node
var _active_turn_target: Node2D

func _ready() -> void:
	zoom = BattleViewConfigScript.DEFAULT_ZOOM
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
	_fallback_anchor = get_parent()

func setup_map(map: BattleMap) -> void:
	if map == null:
		return
	setup_bounds(map.get_camera_bounds())

func setup_bounds(bounds: Rect2) -> void:
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y)
	limit_right = int(bounds.end.x)
	limit_bottom = int(bounds.end.y)

func on_turn_started(controller: MobileController) -> void:
	if controller == null:
		return
	_active_turn_target = controller.get_follow_target()
	if _active_turn_target == null:
		return
	_reparent_camera(_active_turn_target)

func on_projectile_spawned(projectile: Projectile) -> void:
	_reparent_camera(projectile)
	if not projectile.tree_exiting.is_connected(_on_projectile_removed):
		projectile.tree_exiting.connect(_on_projectile_removed, CONNECT_ONE_SHOT)

func _on_projectile_removed() -> void:
	call_deferred("_restore_after_projectile")

func on_battle_ended(_result: MatchResult) -> void:
	pass

func _restore_after_projectile() -> void:
	var target := _find_restore_target()
	if target != null:
		_reparent_camera(target)

func _find_restore_target() -> Node:
	if _active_turn_target != null and is_instance_valid(_active_turn_target):
		return _active_turn_target
	if _fallback_anchor != null and is_instance_valid(_fallback_anchor):
		return _fallback_anchor
	return null

func _reparent_camera(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return
	if get_parent() == target:
		position = Vector2.ZERO
		return
	reparent(target)
	position = Vector2.ZERO
