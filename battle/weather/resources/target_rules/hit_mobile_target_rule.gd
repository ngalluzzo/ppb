class_name HitMobileTargetRule
extends "res://battle/weather/resources/target_rules/weather_status_target_rule.gd"

func get_impact_targets(event, _battle_system, _splash_radius: float = -1.0) -> Array:
	if event == null or event.hit_mobile == null:
		return []
	return [event.hit_mobile]
