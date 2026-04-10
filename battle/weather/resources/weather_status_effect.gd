class_name WeatherStatusEffect
extends Resource

const StatusDefinitionScript = preload("res://mobile/status/status_definition.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherStatusTargetRuleScript = preload("res://battle/weather/resources/target_rules/weather_status_target_rule.gd")

var _status_definition: Resource
@export var status_definition: Resource:
	get:
		return _status_definition
	set(value):
		_status_definition = WeatherResourceValidationScript.require_resource(
			value,
			StatusDefinitionScript,
			"StatusDefinition",
			"WeatherStatusEffect.status_definition"
		)

var _target_rule: Resource
@export var target_rule: Resource:
	get:
		return _target_rule
	set(value):
		_target_rule = WeatherResourceValidationScript.require_resource(
			value,
			WeatherStatusTargetRuleScript,
			"WeatherStatusTargetRule",
			"WeatherStatusEffect.target_rule"
		)

@export var duration_turns: int = 0
@export var stacks: int = 1
@export var source_id_override: String = ""

func get_turn_start_targets(controller, battle_system) -> Array:
	if _target_rule == null:
		return []
	return _target_rule.get_turn_start_targets(controller, battle_system)

func get_impact_targets(event, battle_system, splash_radius: float = -1.0) -> Array:
	if _target_rule == null:
		return []
	return _target_rule.get_impact_targets(event, battle_system, splash_radius)
