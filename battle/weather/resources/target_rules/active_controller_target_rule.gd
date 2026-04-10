class_name ActiveControllerTargetRule
extends "res://battle/weather/resources/target_rules/weather_status_target_rule.gd"

func get_turn_start_targets(controller, _battle_system) -> Array:
	if controller == null:
		return []
	var target_context = controller.get_target_context()
	if target_context == null or target_context.mobile == null:
		return []
	return [target_context.mobile]
