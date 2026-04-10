class_name ImpactService
extends RefCounted

const ImpactContextResolverScript = preload("res://battle/logic/impact/impact_context_resolver.gd")
const ImpactDamageRulesScript = preload("res://battle/logic/impact/impact_damage_rules.gd")
const ImpactStatusRulesScript = preload("res://battle/logic/impact/impact_status_rules.gd")
const ImpactTerrainRulesScript = preload("res://battle/logic/impact/impact_terrain_rules.gd")

var _battle_system: BattleSystem
var _battle_map: BattleMap
var _terrain: Terrain
var _weather_controller

func setup(
	battle_system: BattleSystem,
	battle_map: BattleMap,
	terrain: Terrain,
	weather_controller = null
) -> void:
	_battle_system = battle_system
	_battle_map = battle_map
	_terrain = terrain
	_weather_controller = weather_controller

func resolve(event: ImpactEvent) -> void:
	if event == null or event.impact_def == null:
		return
	var resolution_context: ImpactResolutionContext = ImpactContextResolverScript.resolve(event, _weather_controller)
	ImpactTerrainRulesScript.apply_terrain_damage(event, resolution_context, _terrain)
	if event.hit_mobile != null:
		ImpactDamageRulesScript.apply_direct_damage(event, resolution_context)
	else:
		ImpactDamageRulesScript.apply_splash_damage(
			event,
			resolution_context,
			_battle_system.get_units() if _battle_system != null else []
		)
	ImpactStatusRulesScript.apply_impact_statuses(event, resolution_context, _battle_system, _weather_controller)
