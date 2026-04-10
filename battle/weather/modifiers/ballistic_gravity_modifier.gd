class_name BallisticGravityModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var gravity_multiplier: float = 1.0
@export var gravity_offset: float = 0.0

func modify_ballistics(ctx):
	if ctx == null:
		return null
	ctx.gravity = (ctx.gravity * gravity_multiplier) + gravity_offset
	return ctx
