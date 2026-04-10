class_name MatchResult
extends RefCounted

var winning_team: Team
var context: MatchContext

func _init(p_winning_team: Team, p_context: MatchContext) -> void:
	winning_team = p_winning_team
	context = p_context
