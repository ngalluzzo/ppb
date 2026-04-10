class_name TerrainFragilityModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var drill_power_scalar: float = 1.0

func modify_impact(ctx):
	if ctx == null:
		return null
	ctx.terrain_drill_power *= drill_power_scalar
	return ctx
