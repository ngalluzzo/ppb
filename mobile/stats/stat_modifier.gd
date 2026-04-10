class_name StatModifier
extends Resource

enum ModifierType {
	FLAT,
	PERCENT
}

enum ApplicationMode {
	ON_TICK,
	ON_APPLY,
	PERSISTENT
}

## The stat this modifier affects. e.g. "armor", "health", "damage_taken"
@export var stat: String = ""
## Whether this modifier adds a flat amount or multiplies by a percentage.
@export var modifier_type: ModifierType = ModifierType.FLAT
## The amount to modify. Use negative values to reduce a stat.
@export var amount: float = 0.0
## When this modifier applies its effect.
@export var application_mode: ApplicationMode = ApplicationMode.PERSISTENT
