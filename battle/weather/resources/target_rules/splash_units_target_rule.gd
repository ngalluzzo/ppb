class_name SplashUnitsTargetRule
extends "res://battle/weather/resources/target_rules/weather_status_target_rule.gd"

func get_impact_targets(event, battle_system, splash_radius: float = -1.0) -> Array:
	if event == null or battle_system == null:
		return []
	var radius := splash_radius if splash_radius > 0.0 else event.impact_def.radius
	if radius <= 0.0:
		return []
	var targets: Array = []
	for unit in battle_system.get_units():
		if unit == null or not is_instance_valid(unit):
			continue
		if unit.global_position.distance_to(event.position) <= radius:
			targets.append(unit)
	return targets
