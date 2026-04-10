class_name WinCondition
extends Resource

enum Type {
	LAST_TEAM_STANDING,
	SCORE_THRESHOLD,
	TIME_LIMIT
}

enum LifeRule {
	ONE_LIFE,
	TEAM_POOL,
	UNLIMITED
}

@export var display_name: String = ""
@export var type: Type = Type.LAST_TEAM_STANDING
@export var life_rule: LifeRule = LifeRule.ONE_LIFE
@export var score_threshold: int = 0
@export var time_limit: float = 0.0
@export var turn_duration: float = 20.0
@export var min_teams: int = 2
