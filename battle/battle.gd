extends Node2D

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const MatchWeatherConfigScript = preload("res://battle/weather/resources/match_weather_config.gd")

@export var win_condition: WinCondition
@export var map_catalog: BattleMapCatalog
var _weather_config: Resource
@export var weather_config: Resource:
	get:
		return _weather_config
	set(value):
		_weather_config = WeatherResourceValidationScript.require_resource(
			value,
			MatchWeatherConfigScript,
			"MatchWeatherConfig",
			"Battle.weather_config"
		)
@export var team_a_mobiles: Array[MobileDefinition] = []
@export var team_b_mobiles: Array[MobileDefinition] = []
@export_enum("Human", "AI") var team_a_control_source_kind: int = Team.ControlSourceKind.HUMAN
@export_enum("Human", "AI") var team_b_control_source_kind: int = Team.ControlSourceKind.HUMAN

@onready var battle_system: BattleSystem = $BattleSystem
@onready var battle_camera: BattleCamera = $BattleCamera
@onready var battle_overlay: BattleOverlay = $HUD/BattleOverlay

func _ready() -> void:
	battle_system.turn_started.connect(battle_camera.on_turn_started)
	battle_system.turn_started.connect(battle_overlay.on_turn_started)
	battle_system.turn_ended.connect(battle_overlay.on_turn_ended)
	battle_system.projectile_spawned.connect(battle_camera.on_projectile_spawned)
	battle_system.battle_ended.connect(battle_camera.on_battle_ended)
	battle_system.weather_state_changed.connect(battle_overlay.on_weather_state_changed)
	call_deferred("_start")

func _start() -> void:
	if win_condition == null:
		push_error("Battle: no win_condition configured")
		return
	if map_catalog == null:
		push_error("Battle: no map_catalog configured")
		return
	if team_a_mobiles.is_empty() or team_b_mobiles.is_empty():
		push_error("Battle: both teams need at least one configured MobileDefinition")
		return

	var teams: Array[Team] = [
		Team.new(0, "Team A", team_a_mobiles, team_a_control_source_kind),
		Team.new(1, "Team B", team_b_mobiles, team_b_control_source_kind)
	]
	var context := MatchContext.new(win_condition, map_catalog, teams, weather_config)
	battle_system.configure(context)
	await battle_system.start_match()
	battle_camera.setup_map(battle_system.get_map())
		
