class_name BattleVictoryRules
extends RefCounted

static func evaluate(
	context: MatchContext,
	mobiles: Array,
	mobile_team_map: Dictionary
) -> MatchResult:
	if context == null or context.win_condition == null:
		return null
	match context.win_condition.type:
		WinCondition.Type.LAST_TEAM_STANDING:
			return _evaluate_last_team_standing(context, mobiles, mobile_team_map)
		_:
			return null

static func _evaluate_last_team_standing(
	context: MatchContext,
	mobiles: Array,
	mobile_team_map: Dictionary
) -> MatchResult:
	var living_teams: Array[Team] = []
	for mobile in mobiles:
		var team := mobile_team_map.get(mobile) as Team
		if team != null and not living_teams.has(team):
			living_teams.append(team)
	if living_teams.size() == 1:
		return MatchResult.new(living_teams[0], context)
	return null
