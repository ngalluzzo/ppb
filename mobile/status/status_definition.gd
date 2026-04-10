class_name StatusDefinition
extends Resource

const ResourceValidationScript = preload("res://shared/resource_validation.gd")
const StatModifierScript = preload("res://mobile/stats/stat_modifier.gd")

enum StackPolicy {
	REFRESH,
	STACK
}

enum Polarity {
	BUFF,
	DEBUFF,
	NEUTRAL
}

@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var polarity: Polarity = Polarity.NEUTRAL
@export var tint: Color = Color(0.85, 0.88, 0.94, 1.0)
@export var short_label: String = ""
@export var priority: int = 0
@export var duration_turns: int = 1
@export var stack_policy: StackPolicy = StackPolicy.REFRESH
@export var max_stacks: int = 1
@export var tags: Array[String] = []

var _modifiers: Array[Resource] = []
@export var modifiers: Array[Resource]:
	get:
		return _modifiers
	set(value):
		_modifiers = ResourceValidationScript.filter_resources(
			value,
			StatModifierScript,
			"StatModifier",
			"StatusDefinition.modifiers"
		)
