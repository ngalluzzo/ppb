@tool
class_name BattleSystem
extends Node2D

const MobileScene = preload("res://mobile/mobile.tscn")
const ControllerScript = preload("res://mobile/controls/mobile_controller.gd")
const HumanControlSourceScript = preload("res://mobile/controls/human_control_source.gd")
const AiControlSourceScript = preload("res://mobile/controls/ai_control_source.gd")
const ShotExecutionServiceScript = preload("res://weapon/shot/shot_execution_service.gd")
const ImpactServiceScript = preload("res://battle/impact_service.gd")
const WeatherControllerScript = preload("res://battle/weather/weather_controller.gd")
const MatchWeatherConfigScript = preload("res://battle/weather/resources/match_weather_config.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherStateScript = preload("res://battle/weather/weather_state.gd")
const BattleRuntimeStateScript = preload("res://battle/logic/battle_runtime_state.gd")
const BattleTurnRulesScript = preload("res://battle/logic/battle_turn_rules.gd")
const BattleVictoryRulesScript = preload("res://battle/logic/battle_victory_rules.gd")
const BattleSpawnPlannerScript = preload("res://battle/logic/battle_spawn_planner.gd")
const BattleTurnEffectsScript = preload("res://battle/logic/battle_turn_effects.gd")

signal turn_started(controller: MobileController)
signal turn_ended(controller: MobileController)
signal projectile_spawned(projectile: Projectile)
signal battle_ended(result: MatchResult)
signal weather_state_changed(state)
signal forecast_advanced(state)
signal wind_changed(state)

const INTERNAL_TURN_TIMER_NAME := "__BattleTurnTimer"
const INTERNAL_SHOT_EXECUTION_SERVICE_NAME := "__ShotExecutionService"
const INTERNAL_WEATHER_CONTROLLER_NAME := "__WeatherController"
const INTERNAL_PREVIEW_WORLD_NAME := "__EditorPreviewWorld"

const PREVIEW_FILL := Color(0.30, 0.70, 0.98, 0.06)
const PREVIEW_OUTLINE := Color(0.30, 0.70, 0.98, 0.95)
const PREVIEW_FLOOR := Color(0.46, 0.86, 0.42, 0.95)
const PREVIEW_WALL := Color(0.97, 0.39, 0.39, 0.95)
const PREVIEW_IMPACT := Color(0.99, 0.84, 0.36, 0.95)

var _editor_preview_enabled_value: bool = false
var _editor_preview_label_value: String = "Battle Preview Host"
var _editor_preview_show_gizmos_value: bool = true
var _editor_preview_bounds_value: Rect2 = Rect2(-160.0, -80.0, 1440.0, 720.0)
var _editor_preview_floor_y_value: float = 360.0
var _editor_preview_wall_x_value: float = 1100.0
var _editor_preview_weather_config_value: Resource
var _editor_preview_seed_value: int = 1

@export_group("Editor Preview")
@export var editor_preview_enabled: bool:
	get:
		return _editor_preview_enabled_value
	set(value):
		if _editor_preview_enabled_value == value:
			return
		_editor_preview_enabled_value = value
		if is_inside_tree():
			if value:
				call_deferred("begin_editor_preview")
			else:
				end_editor_preview()
		_on_editor_preview_authoring_changed()

@export var editor_preview_label: String = "Battle Preview Host":
	get:
		return _editor_preview_label_value
	set(value):
		_editor_preview_label_value = value.strip_edges() if value != null else "Battle Preview Host"
		if _editor_preview_label_value == "":
			_editor_preview_label_value = "Battle Preview Host"
		_on_editor_preview_authoring_changed()

@export var editor_preview_show_gizmos: bool = true:
	get:
		return _editor_preview_show_gizmos_value
	set(value):
		_editor_preview_show_gizmos_value = value
		_on_editor_preview_authoring_changed()

@export var editor_preview_bounds: Rect2 = Rect2(-160.0, -80.0, 1440.0, 720.0):
	get:
		return _editor_preview_bounds_value
	set(value):
		_editor_preview_bounds_value = value
		_on_editor_preview_authoring_changed()

@export var editor_preview_floor_y: float = 360.0:
	get:
		return _editor_preview_floor_y_value
	set(value):
		_editor_preview_floor_y_value = value
		_on_editor_preview_authoring_changed()

@export var editor_preview_wall_x: float = 1100.0:
	get:
		return _editor_preview_wall_x_value
	set(value):
		_editor_preview_wall_x_value = value
		_on_editor_preview_authoring_changed()

@export var editor_preview_weather_config: Resource:
	get:
		return _editor_preview_weather_config_value
	set(value):
		_editor_preview_weather_config_value = WeatherResourceValidationScript.require_resource(
			value,
			MatchWeatherConfigScript,
			"MatchWeatherConfig",
			"BattleSystem.editor_preview_weather_config"
		)
		if _editor_preview_enabled_value and is_inside_tree():
			call_deferred("begin_editor_preview")
		_on_editor_preview_authoring_changed()

@export var editor_preview_seed: int = 1:
	get:
		return _editor_preview_seed_value
	set(value):
		_editor_preview_seed_value = value
		if _editor_preview_enabled_value and is_inside_tree():
			call_deferred("begin_editor_preview")
		_on_editor_preview_authoring_changed()

var _runtime_state: BattleRuntimeState
var _mobiles: Array[Mobile] = []
var _controllers: Array[MobileController] = []
var _mobile_team_map: Dictionary = {}
var _mobile_controller_map: Dictionary = {}
var _map: BattleMap
var _turn_timer: Timer
var _shot_execution_service: ShotExecutionService
var _impact_service: ImpactService
var _weather_controller: WeatherController
var _editor_preview_active: bool = false
var _editor_preview_world_root: Node2D
var _editor_last_impact_position: Variant
var _editor_last_impact_label: String = ""

func _ready() -> void:
	_ensure_runtime_services()
	if Engine.is_editor_hint():
		_on_editor_preview_authoring_changed()
		if _editor_preview_enabled_value:
			call_deferred("begin_editor_preview")

func _physics_process(delta: float) -> void:
	for mobile in _mobiles:
		if mobile == null or not is_instance_valid(mobile):
			continue
		var controller := _mobile_controller_map.get(mobile) as MobileController
		if controller != null and controller.is_active():
			continue
		mobile.step_locomotion(0, 0.0, delta)
	if Engine.is_editor_hint() and _editor_preview_active and _editor_preview_show_gizmos_value:
		queue_redraw()

func configure(context: MatchContext) -> void:
	_ensure_runtime_services()
	_runtime_state = BattleRuntimeStateScript.new(context)
	if _weather_controller != null and context != null:
		_weather_controller.setup(context.weather_config, context.get_deterministic_seed())
	_on_editor_preview_authoring_changed()

func start_match() -> void:
	var context := _get_context()
	if context == null:
		push_error("BattleSystem: no MatchContext configured")
		return
	await _load_map()
	await _spawn_runtime_units()
	_begin_turn()

func submit_shot_event(event: ShotEvent) -> void:
	if event == null or _runtime_state == null:
		return
	_runtime_state = BattleTurnRulesScript.on_shot_submitted(_runtime_state, event.projectile_count)
	_turn_timer.stop()
	_set_active_controller_locked(true)
	_shot_execution_service.execute(event, self)
	_on_editor_preview_authoring_changed()

func register_projectile(projectile: Projectile, _event: ShotEvent) -> void:
	if projectile == null:
		return
	projectile_spawned.emit(projectile)
	_on_editor_preview_authoring_changed()

func resolve_impact(event: ImpactEvent) -> void:
	if event == null or _runtime_state == null:
		return
	_capture_editor_impact(event)
	_impact_service.resolve(event)
	_runtime_state = BattleTurnRulesScript.on_projectile_resolved(_runtime_state)
	if _runtime_state.current_phase == BattleRuntimeState.Phase.TURN_END and _runtime_state.projectiles_in_flight == 0:
		_finish_turn()
	_on_editor_preview_authoring_changed()

func get_map() -> BattleMap:
	return _map

func get_units() -> Array[Mobile]:
	return _mobiles

func get_weather_state() -> WeatherState:
	if _weather_controller == null or _runtime_state == null:
		return WeatherStateScript.neutral()
	return _weather_controller.get_weather_state()

func get_weather_controller() -> WeatherController:
	return _weather_controller

func get_active_controller() -> MobileController:
	if _controllers.is_empty() or _runtime_state == null:
		return null
	return _controllers[_runtime_state.active_index % _controllers.size()]

func get_world_root() -> Node:
	if _editor_preview_active:
		return _ensure_editor_preview_world_root()
	return get_parent() if get_parent() != null else self

func begin_editor_preview(
	p_label: String = "",
	p_weather_config: Resource = null,
	p_seed: int = -1
) -> void:
	_ensure_runtime_services()
	if p_label.strip_edges() != "":
		_editor_preview_label_value = p_label.strip_edges()
	if p_weather_config != null:
		_editor_preview_weather_config_value = WeatherResourceValidationScript.require_resource(
			p_weather_config,
			MatchWeatherConfigScript,
			"MatchWeatherConfig",
			"BattleSystem.begin_editor_preview(weather_config)"
		)
	if p_seed >= 0:
		_editor_preview_seed_value = p_seed
	_stop_turn_timer()
	_clear_runtime_entities()
	_clear_loaded_map()
	clear_editor_preview_world()
	_runtime_state = BattleRuntimeStateScript.new()
	_editor_preview_active = true
	_editor_preview_enabled_value = true
	_ensure_editor_preview_world_root()
	if _weather_controller != null:
		_weather_controller.setup(_editor_preview_weather_config_value, _editor_preview_seed_value)
	_on_editor_preview_authoring_changed()

func restart_editor_preview() -> void:
	begin_editor_preview(_editor_preview_label_value, _editor_preview_weather_config_value, _editor_preview_seed_value)

func end_editor_preview() -> void:
	_stop_turn_timer()
	_clear_runtime_entities()
	_clear_loaded_map()
	clear_editor_preview_world()
	_runtime_state = null
	_editor_preview_active = false
	_editor_preview_enabled_value = false
	_editor_last_impact_position = null
	_editor_last_impact_label = ""
	_on_editor_preview_authoring_changed()

func clear_editor_preview_world() -> void:
	var preview_root := _ensure_editor_preview_world_root()
	if preview_root == null:
		return
	for child in preview_root.get_children():
		child.queue_free()
	_editor_last_impact_position = null
	_editor_last_impact_label = ""
	_on_editor_preview_authoring_changed()

func is_editor_preview_active() -> bool:
	return _editor_preview_active

func get_preview_debug_snapshot() -> Dictionary:
	var weather_state := get_weather_state()
	return {
		"active": _editor_preview_active,
		"label": _editor_preview_label_value,
		"phase": _phase_name(_runtime_state.current_phase if _runtime_state != null else BattleRuntimeState.Phase.WAITING),
		"turn_index": _runtime_state.turn_index if _runtime_state != null else -1,
		"projectiles_in_flight": _runtime_state.projectiles_in_flight if _runtime_state != null else 0,
		"mobile_count": _mobiles.size(),
		"controller_count": _controllers.size(),
		"has_map": _map != null and is_instance_valid(_map),
		"world_root": str(get_path_to(get_world_root())) if get_world_root() != null and get_world_root() != self else ".",
		"weather_name": _resolve_active_weather_name(weather_state),
		"wind_vector": weather_state.wind_vector if weather_state != null else Vector2.ZERO,
		"last_impact_position": _editor_last_impact_position if _editor_last_impact_position != null else Vector2.ZERO,
		"last_impact_label": _editor_last_impact_label,
	}

func _draw() -> void:
	if not Engine.is_editor_hint() or not _editor_preview_show_gizmos_value:
		return
	_draw_preview_bounds()
	_draw_preview_guides()
	_draw_preview_labels()
	_draw_preview_last_impact()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if _editor_preview_bounds_value.size.x <= 0.0 or _editor_preview_bounds_value.size.y <= 0.0:
		warnings.append("editor_preview_bounds must have positive width and height.")
	if _editor_preview_wall_x_value <= _editor_preview_bounds_value.position.x or _editor_preview_wall_x_value >= _editor_preview_bounds_value.end.x:
		warnings.append("editor_preview_wall_x should sit inside editor_preview_bounds.")
	if _editor_preview_floor_y_value <= _editor_preview_bounds_value.position.y or _editor_preview_floor_y_value >= _editor_preview_bounds_value.end.y:
		warnings.append("editor_preview_floor_y should sit inside editor_preview_bounds.")
	return warnings

func _ensure_runtime_services() -> void:
	_turn_timer = get_node_or_null(INTERNAL_TURN_TIMER_NAME) as Timer
	if _turn_timer == null:
		_turn_timer = Timer.new()
		_turn_timer.name = INTERNAL_TURN_TIMER_NAME
		_turn_timer.one_shot = true
		add_child(_turn_timer, false, Node.INTERNAL_MODE_FRONT)
	if not _turn_timer.timeout.is_connected(_on_turn_timer_expired):
		_turn_timer.timeout.connect(_on_turn_timer_expired)

	_shot_execution_service = get_node_or_null(INTERNAL_SHOT_EXECUTION_SERVICE_NAME) as ShotExecutionService
	if _shot_execution_service == null:
		_shot_execution_service = ShotExecutionServiceScript.new()
		_shot_execution_service.name = INTERNAL_SHOT_EXECUTION_SERVICE_NAME
		add_child(_shot_execution_service, false, Node.INTERNAL_MODE_FRONT)

	_impact_service = _impact_service if _impact_service != null else ImpactServiceScript.new()

	_weather_controller = get_node_or_null(INTERNAL_WEATHER_CONTROLLER_NAME) as WeatherController
	if _weather_controller == null:
		_weather_controller = WeatherControllerScript.new()
		_weather_controller.name = INTERNAL_WEATHER_CONTROLLER_NAME
		add_child(_weather_controller, false, Node.INTERNAL_MODE_FRONT)
	if not _weather_controller.weather_state_changed.is_connected(_on_weather_state_changed_internal):
		_weather_controller.weather_state_changed.connect(_on_weather_state_changed_internal)
	if not _weather_controller.forecast_advanced.is_connected(_on_forecast_advanced_internal):
		_weather_controller.forecast_advanced.connect(_on_forecast_advanced_internal)
	if not _weather_controller.wind_changed.is_connected(_on_wind_changed_internal):
		_weather_controller.wind_changed.connect(_on_wind_changed_internal)

func _ensure_editor_preview_world_root() -> Node2D:
	_editor_preview_world_root = get_node_or_null(INTERNAL_PREVIEW_WORLD_NAME) as Node2D
	if _editor_preview_world_root == null:
		_editor_preview_world_root = Node2D.new()
		_editor_preview_world_root.name = INTERNAL_PREVIEW_WORLD_NAME
		add_child(_editor_preview_world_root, false, Node.INTERNAL_MODE_FRONT)
	return _editor_preview_world_root

func _load_map() -> void:
	var context := _get_context()
	if context == null:
		return
	if context.map_catalog == null:
		push_error("BattleSystem: no BattleMapCatalog configured")
		return
	if context.map_catalog.map_scene == null:
		push_error("BattleSystem: BattleMapCatalog has no map_scene")
		return
	_map = context.map_catalog.map_scene.instantiate() as BattleMap
	if _map == null:
		push_error("BattleSystem: could not instantiate BattleMap")
		return
	get_parent().add_child(_map)
	if not _map.is_node_ready():
		await _map.ready
	_map.setup()
	_impact_service.setup(self, _map, _map.get_terrain(), _weather_controller)

func _spawn_runtime_units() -> void:
	if _map == null:
		push_error("BattleSystem: no BattleMap loaded before spawning mobiles")
		return
	var requests: Array[BattleSpawnRequest] = BattleSpawnPlannerScript.plan_spawns(_get_context(), _map)
	for request in requests:
		await _spawn_from_request(request)

func _spawn_from_request(request: BattleSpawnRequest) -> void:
	if request == null or request.mobile_def == null or request.team == null:
		return
	var mobile: Mobile = MobileScene.instantiate()
	mobile.mobile_def = request.mobile_def
	mobile.team_index = request.team.team_index
	mobile.combatant_id = request.combatant_id
	get_world_root().add_child(mobile)
	if not mobile.is_node_ready():
		await mobile.ready
	mobile.global_position = request.spawn_position
	mobile.facing_direction = request.facing_direction

	var controller: MobileController = ControllerScript.new()
	add_child(controller)
	controller.setup(mobile, _create_control_source(request.control_source_kind), self)
	mobile.stat_container.died.connect(func(): _on_mobile_died(mobile))

	_mobile_team_map[mobile] = request.team
	_mobile_controller_map[mobile] = controller
	_mobiles.append(mobile)
	_controllers.append(controller)

func _begin_turn() -> void:
	if _runtime_state == null or _controllers.is_empty():
		return
	_runtime_state = BattleTurnRulesScript.begin_action_turn(_runtime_state, _controllers.size())
	var active := get_active_controller()
	BattleTurnEffectsScript.apply_turn_start(active, self, _weather_controller, _runtime_state.turn_index)
	_set_active_controller_locked(false)
	var context := _get_context()
	if context != null and context.win_condition != null:
		_turn_timer.start(context.win_condition.turn_duration)
	turn_started.emit(active)

func _finish_turn() -> void:
	if _runtime_state == null:
		return
	if _controllers.is_empty():
		_runtime_state.current_phase = BattleRuntimeState.Phase.WAITING
		return
	var active := get_active_controller()
	turn_ended.emit(active)
	_runtime_state = BattleTurnRulesScript.advance_to_next_controller(_runtime_state, _controllers.size())
	_begin_turn()

func _on_turn_timer_expired() -> void:
	if _runtime_state == null:
		return
	_runtime_state = BattleTurnRulesScript.on_turn_timeout(_runtime_state)
	if _runtime_state.current_phase == BattleRuntimeState.Phase.TURN_END:
		_set_active_controller_locked(true)
		_finish_turn()

func _on_mobile_died(mobile: Mobile) -> void:
	var controller := _mobile_controller_map.get(mobile) as MobileController
	var controller_index := _controllers.find(controller)

	var mobile_index := _mobiles.find(mobile)
	if mobile_index != -1:
		_mobiles.remove_at(mobile_index)
	_mobile_team_map.erase(mobile)
	_mobile_controller_map.erase(mobile)

	if controller != null:
		if controller_index != -1:
			_controllers.remove_at(controller_index)
		controller.queue_free()

	if _runtime_state != null:
		_runtime_state = BattleTurnRulesScript.on_controller_removed(
			_runtime_state,
			controller_index,
			_controllers.size()
		)

	var result := BattleVictoryRulesScript.evaluate(_get_context(), _mobiles, _mobile_team_map)
	if result != null:
		battle_ended.emit(result)
	_on_editor_preview_authoring_changed()

func _set_active_controller_locked(locked: bool) -> void:
	var controller := get_active_controller()
	if controller == null:
		return
	controller.set_active(not locked)

func _create_control_source(control_source_kind: int) -> MobileControlSource:
	if control_source_kind == Team.ControlSourceKind.AI:
		return AiControlSourceScript.new()
	return HumanControlSourceScript.new()

func _get_context() -> MatchContext:
	return _runtime_state.context if _runtime_state != null else null

func _stop_turn_timer() -> void:
	if _turn_timer != null:
		_turn_timer.stop()
	if _shot_execution_service != null:
		_shot_execution_service.cancel_active_executions()

func _clear_runtime_entities() -> void:
	for mobile in _mobiles:
		if mobile != null and is_instance_valid(mobile):
			mobile.queue_free()
	for controller in _controllers:
		if controller != null and is_instance_valid(controller):
			controller.queue_free()
	_mobiles.clear()
	_controllers.clear()
	_mobile_team_map.clear()
	_mobile_controller_map.clear()

func _clear_loaded_map() -> void:
	if _map != null and is_instance_valid(_map):
		_map.queue_free()
	_map = null

func _capture_editor_impact(event: ImpactEvent) -> void:
	if not _editor_preview_active or event == null:
		return
	_editor_last_impact_position = to_local(event.position)
	_editor_last_impact_label = "terrain" if event.hit_mobile == null else "mobile"

func _on_weather_state_changed_internal(state) -> void:
	weather_state_changed.emit(state)
	_on_editor_preview_authoring_changed()

func _on_forecast_advanced_internal(state) -> void:
	forecast_advanced.emit(state)
	_on_editor_preview_authoring_changed()

func _on_wind_changed_internal(state) -> void:
	wind_changed.emit(state)
	_on_editor_preview_authoring_changed()

func _on_editor_preview_authoring_changed() -> void:
	update_configuration_warnings()
	queue_redraw()

func _draw_preview_bounds() -> void:
	draw_rect(_editor_preview_bounds_value, PREVIEW_FILL, true)
	draw_rect(_editor_preview_bounds_value, PREVIEW_OUTLINE, false, 3.0)

func _draw_preview_guides() -> void:
	draw_line(
		Vector2(_editor_preview_bounds_value.position.x, _editor_preview_floor_y_value),
		Vector2(_editor_preview_bounds_value.end.x, _editor_preview_floor_y_value),
		PREVIEW_FLOOR,
		3.0
	)
	draw_line(
		Vector2(_editor_preview_wall_x_value, _editor_preview_bounds_value.position.y),
		Vector2(_editor_preview_wall_x_value, _editor_preview_bounds_value.end.y),
		PREVIEW_WALL,
		3.0
	)
	draw_circle(Vector2.ZERO, 5.0, PREVIEW_OUTLINE)

func _draw_preview_labels() -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var snapshot := get_preview_debug_snapshot()
	var top_left := _editor_preview_bounds_value.position + Vector2(12.0, 22.0)
	draw_string(font, top_left, _editor_preview_label_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, PREVIEW_OUTLINE)
	draw_string(
		font,
		top_left + Vector2(0.0, 18.0),
		"preview=%s phase=%s projectiles=%s turn=%s" % [
			"on" if snapshot.active else "off",
			snapshot.phase,
			snapshot.projectiles_in_flight,
			snapshot.turn_index
		],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		PREVIEW_OUTLINE
	)
	draw_string(
		font,
		top_left + Vector2(0.0, 36.0),
		"weather=%s wind=(%.1f, %.1f) root=%s" % [
			snapshot.weather_name,
			snapshot.wind_vector.x,
			snapshot.wind_vector.y,
			snapshot.world_root
		],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		PREVIEW_OUTLINE
	)
	draw_string(
		font,
		Vector2(_editor_preview_bounds_value.position.x + 12.0, _editor_preview_floor_y_value - 8.0),
		"floor y=%.0f" % _editor_preview_floor_y_value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		PREVIEW_FLOOR
	)
	draw_string(
		font,
		Vector2(_editor_preview_wall_x_value + 8.0, _editor_preview_bounds_value.position.y + 22.0),
		"wall x=%.0f" % _editor_preview_wall_x_value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		PREVIEW_WALL
	)

func _draw_preview_last_impact() -> void:
	if _editor_last_impact_position == null:
		return
	var impact_position: Vector2 = _editor_last_impact_position
	draw_circle(impact_position, 7.0, PREVIEW_IMPACT)
	var font := ThemeDB.fallback_font
	if font != null:
		draw_string(
			font,
			impact_position + Vector2(10.0, -10.0),
			"impact: %s" % _editor_last_impact_label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			PREVIEW_IMPACT
		)

func _resolve_active_weather_name(state: WeatherState) -> String:
	if state == null or state.active_event == null or state.active_event.definition == null:
		return "clear"
	return state.active_event.definition.display_name

func _phase_name(phase: int) -> String:
	match phase:
		BattleRuntimeState.Phase.ACTION:
			return "ACTION"
		BattleRuntimeState.Phase.RESOLVING:
			return "RESOLVING"
		BattleRuntimeState.Phase.TURN_END:
			return "TURN_END"
		_:
			return "WAITING"
