class_name ChargeRateModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var charge_rate_scalar: float = 1.0

func modify_control(ctx):
	if ctx == null:
		return null
	ctx.charge_rate_scalar *= charge_rate_scalar
	return ctx
