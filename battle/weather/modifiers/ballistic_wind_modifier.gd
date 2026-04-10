class_name BallisticWindModifier
extends "res://battle/weather/modifiers/weather_modifier.gd"

@export var wind_multiplier: float = 1.0
@export var wind_offset: Vector2 = Vector2.ZERO

func modify_ballistics(ctx):
	if ctx == null:
		return null
	ctx.wind_vector = (ctx.wind_vector * wind_multiplier) + wind_offset
	return ctx
