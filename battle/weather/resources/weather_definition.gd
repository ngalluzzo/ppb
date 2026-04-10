class_name WeatherDefinition
extends Resource

const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherModifierScript = preload("res://battle/weather/modifiers/weather_modifier.gd")
const WeatherStatusEffectScript = preload("res://battle/weather/resources/weather_status_effect.gd")

@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var duration_turns: int = 1
@export var forecast_color: Color = Color.WHITE
var _modifiers: Array[Resource] = []
@export var modifiers: Array[Resource]:
	get:
		return _modifiers
	set(value):
		_modifiers = WeatherResourceValidationScript.filter_resources(
			value,
			WeatherModifierScript,
			"WeatherModifier",
			"WeatherDefinition.modifiers"
		)

var _turn_start_status_effects: Array[Resource] = []
@export var turn_start_status_effects: Array[Resource]:
	get:
		return _turn_start_status_effects
	set(value):
		_turn_start_status_effects = WeatherResourceValidationScript.filter_resources(
			value,
			WeatherStatusEffectScript,
			"WeatherStatusEffect",
			"WeatherDefinition.turn_start_status_effects"
		)

var _impact_status_effects: Array[Resource] = []
@export var impact_status_effects: Array[Resource]:
	get:
		return _impact_status_effects
	set(value):
		_impact_status_effects = WeatherResourceValidationScript.filter_resources(
			value,
			WeatherStatusEffectScript,
			"WeatherStatusEffect",
			"WeatherDefinition.impact_status_effects"
		)
