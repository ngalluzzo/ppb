class_name DamageScalarModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var damage_scalar: float = 1.0

func modify_impact(ctx):
	if ctx == null:
		return null
	ctx.damage *= damage_scalar
	return ctx
