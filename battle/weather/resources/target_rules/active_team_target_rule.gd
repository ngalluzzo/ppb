class_name ActiveTeamTargetRule
extends "res://battle/weather/resources/target_rules/weather_status_target_rule.gd"

func get_turn_start_targets(controller, battle_system) -> Array:
	if controller == null or battle_system == null:
		return []
	var target_context = controller.get_target_context()
	if target_context == null or target_context.team_index < 0:
		return []
	var targets: Array = []
	for unit in battle_system.get_units():
		if unit != null and is_instance_valid(unit) and unit.team_index == target_context.team_index:
			targets.append(unit)
	return targets
