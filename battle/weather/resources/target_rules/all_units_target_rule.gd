class_name AllUnitsTargetRule
extends "res://battle/weather/resources/target_rules/weather_status_target_rule.gd"

func get_turn_start_targets(_controller, battle_system) -> Array:
	if battle_system == null:
		return []
	var targets: Array = []
	for unit in battle_system.get_units():
		if unit != null and is_instance_valid(unit):
			targets.append(unit)
	return targets
