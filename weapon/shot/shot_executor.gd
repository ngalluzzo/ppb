@tool
class_name ShotExecutor
extends Node

signal completed(event: ShotEvent, spawned_count: int)

var _execution_service: ShotExecutionService
var _event: ShotEvent
var _battle_system: BattleSystem
var _canceled: bool = false

func setup(execution_service: ShotExecutionService, event: ShotEvent, battle_system: BattleSystem) -> void:
	_execution_service = execution_service
	_event = event
	_battle_system = battle_system
	call_deferred("_run")

func cancel() -> void:
	_canceled = true
	if is_inside_tree():
		queue_free()

func _run() -> void:
	if _canceled or _execution_service == null or _event == null or _battle_system == null:
		queue_free()
		return
	if _event.projectile_definition == null:
		queue_free()
		return
	var spawned_count: int = 0
	for projectile_index in _event.projectile_count:
		if _canceled:
			queue_free()
			return
		if projectile_index > 0 and _event.stagger_delay > 0.0:
			await get_tree().create_timer(_event.stagger_delay).timeout
			if _canceled:
				queue_free()
				return
		_execution_service.spawn_projectile(_event, projectile_index, _battle_system)
		spawned_count += 1
	completed.emit(_event, spawned_count)
	queue_free()
