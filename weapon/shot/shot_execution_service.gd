@tool
class_name ShotExecutionService
extends Node

const ProjectileScene = preload("res://weapon/projectile/projectile.tscn")
const ShotExecutorScript = preload("res://weapon/shot/shot_executor.gd")
const WorldLifecycleAdapterScript = preload("res://shared/runtime/world_lifecycle_adapter.gd")

signal execution_started(snapshot: Dictionary)
signal projectile_spawned(snapshot: Dictionary)
signal execution_finished(snapshot: Dictionary)

var _lifecycle_adapter: WorldLifecycleAdapter = WorldLifecycleAdapterScript.new()
var _active_executors: Array[ShotExecutor] = []
var _last_execution_snapshot: Dictionary = {
	"mode": "idle",
	"shot_id": 0,
	"projectile_count": 0,
	"spawned_count": 0,
	"stagger_delay": 0.0,
	"active_executors": 0,
}

func _exit_tree() -> void:
	cancel_active_executions()

func execute(event: ShotEvent, battle_system: BattleSystem) -> void:
	if event == null or battle_system == null:
		return
	if event.projectile_definition == null:
		push_error("ShotExecutionService: ShotEvent %d has no ProjectileDefinition" % event.shot_id)
		return
	var execution_mode := "staggered" if event.stagger_delay > 0.0 and event.projectile_count > 1 else "immediate"
	_emit_execution_started(event, execution_mode)
	if execution_mode == "staggered":
		var executor: ShotExecutor = ShotExecutorScript.new()
		_register_executor(executor)
		_lifecycle_adapter.add_to_parent(battle_system, executor)
		executor.setup(self, event, battle_system)
		return
	for projectile_index in event.projectile_count:
		_spawn_projectile(event, projectile_index, battle_system)
	_emit_execution_finished(event, event.projectile_count, "immediate")

func spawn_projectile(event: ShotEvent, projectile_index: int, battle_system: BattleSystem) -> void:
	_spawn_projectile(event, projectile_index, battle_system)

func cancel_active_executions() -> void:
	for executor in _active_executors:
		if executor != null and is_instance_valid(executor):
			executor.cancel()
	_active_executors.clear()
	_last_execution_snapshot.active_executors = 0

func get_debug_snapshot() -> Dictionary:
	return _last_execution_snapshot.duplicate(true)

func _spawn_projectile(event: ShotEvent, projectile_index: int, battle_system: BattleSystem) -> void:
	var projectile: Projectile = ProjectileScene.instantiate() as Projectile
	if projectile == null:
		push_error("ShotExecutionService: could not instantiate projectile scene")
		return
	projectile.initialize_from_shot(event, projectile_index, battle_system)
	_lifecycle_adapter.add_to_parent(battle_system.get_world_root(), projectile)
	projectile.sync_spawn_transform(event.muzzle_position)
	battle_system.register_projectile(projectile, event)
	_emit_projectile_spawned(event, projectile_index)

func _register_executor(executor: ShotExecutor) -> void:
	if executor == null:
		return
	_active_executors.append(executor)
	if not executor.completed.is_connected(_on_executor_completed):
		executor.completed.connect(_on_executor_completed)
	if not executor.tree_exited.is_connected(_on_executor_tree_exited.bind(executor)):
		executor.tree_exited.connect(_on_executor_tree_exited.bind(executor), CONNECT_ONE_SHOT)
	_last_execution_snapshot.active_executors = _active_executors.size()

func _on_executor_completed(event: ShotEvent, spawned_count: int) -> void:
	_emit_execution_finished(event, spawned_count, "staggered")

func _on_executor_tree_exited(executor: ShotExecutor) -> void:
	_active_executors.erase(executor)
	_last_execution_snapshot.active_executors = _active_executors.size()

func _emit_execution_started(event: ShotEvent, mode: String) -> void:
	_last_execution_snapshot = {
		"mode": mode,
		"shot_id": event.shot_id if event != null else 0,
		"projectile_count": event.projectile_count if event != null else 0,
		"spawned_count": 0,
		"stagger_delay": event.stagger_delay if event != null else 0.0,
		"active_executors": _active_executors.size(),
	}
	execution_started.emit(get_debug_snapshot())

func _emit_projectile_spawned(event: ShotEvent, projectile_index: int) -> void:
	_last_execution_snapshot.spawned_count = int(_last_execution_snapshot.get("spawned_count", 0)) + 1
	projectile_spawned.emit({
		"shot_id": event.shot_id if event != null else 0,
		"projectile_index": projectile_index,
		"spawned_count": _last_execution_snapshot.spawned_count,
		"projectile_count": event.projectile_count if event != null else 0,
		"active_executors": _active_executors.size(),
	})

func _emit_execution_finished(event: ShotEvent, spawned_count: int, mode: String) -> void:
	_last_execution_snapshot.mode = mode
	_last_execution_snapshot.shot_id = event.shot_id if event != null else 0
	_last_execution_snapshot.projectile_count = event.projectile_count if event != null else 0
	_last_execution_snapshot.spawned_count = spawned_count
	_last_execution_snapshot.stagger_delay = event.stagger_delay if event != null else 0.0
	_last_execution_snapshot.active_executors = _active_executors.size()
	execution_finished.emit(get_debug_snapshot())
