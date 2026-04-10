class_name PowerScalarModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var power_scalar: float = 1.0

func modify_ballistics(ctx):
	if ctx == null:
		return null
	ctx.power_scalar *= power_scalar
	return ctx
