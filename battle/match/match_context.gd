class_name MatchContext
extends RefCounted

var win_condition: WinCondition
var map_catalog: BattleMapCatalog
var weather_config
var teams: Array[Team] = []

func _init(
	p_win_condition: WinCondition,
	p_map_catalog: BattleMapCatalog,
	p_teams: Array[Team],
	p_weather_config = null
) -> void:
	win_condition = p_win_condition
	map_catalog = p_map_catalog
	teams = p_teams
	weather_config = p_weather_config

func get_all_mobile_defs() -> Array[MobileDefinition]:
	var all: Array[MobileDefinition] = []
	for team in teams:
		all.append_array(team.mobiles)
	return all

func get_team(team_index: int) -> Team:
	for team in teams:
		if team.team_index == team_index:
			return team
	return null

func team_count() -> int:
	return teams.size()

func get_deterministic_seed() -> int:
	var parts: Array[String] = [
		win_condition.resource_path if win_condition != null else "",
		map_catalog.resource_path if map_catalog != null else "",
		weather_config.resource_path if weather_config != null else ""
	]
	for team in teams:
		if team == null:
			continue
		parts.append("%s:%s:%s" % [team.team_index, team.team_name, team.control_source_kind])
		for mobile_def in team.mobiles:
			if mobile_def == null:
				continue
			parts.append(mobile_def.resource_path if mobile_def.resource_path != "" else mobile_def.name)
	return int(hash("|".join(parts)))
