class_name WeatherModifierResolver
extends RefCounted

const WeatherBallisticsContextScript = preload("res://battle/weather/weather_ballistics_context.gd")
const WeatherControlContextScript = preload("res://battle/weather/weather_control_context.gd")
const WeatherImpactContextScript = preload("res://battle/weather/weather_impact_context.gd")
const WeatherModifierScript = preload("res://battle/weather/modifiers/weather_modifier.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")

static func get_active_modifiers(state: WeatherRuntimeState) -> Array:
	if state == null or state.active_event == null:
		return []
	var modifiers: Array = []
	for modifier in state.active_event.resolved_modifiers:
		if WeatherResourceValidationScript.matches_script(modifier, WeatherModifierScript):
			modifiers.append(modifier)
	return modifiers

static func build_ballistics_context(state: WeatherRuntimeState, shot_event: ShotEvent) -> WeatherBallisticsContext:
	var wind_vector: Vector2 = state.wind_vector if state != null else Vector2.ZERO
	var ctx := WeatherBallisticsContextScript.new(
		shot_event.base_velocity,
		shot_event.gravity,
		shot_event.aim_direction,
		wind_vector,
		shot_event.base_velocity.length(),
		1.0
	)
	for modifier in get_active_modifiers(state):
		ctx = modifier.modify_ballistics(ctx)
	if ctx == null:
		return WeatherBallisticsContextScript.new()
	var direction: Vector2 = ctx.aim_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	ctx.base_velocity = direction * (ctx.launch_speed * ctx.power_scalar)
	return ctx

static func build_impact_context(state: WeatherRuntimeState, event: ImpactEvent) -> WeatherImpactContext:
	var ctx := WeatherImpactContextScript.new(
		event.impact_def.damage if event != null and event.impact_def != null else 0.0,
		event.impact_def.radius if event != null and event.impact_def != null else 0.0,
		event.impact_def.drill_power if event != null and event.impact_def != null else 0.0
	)
	for modifier in get_active_modifiers(state):
		ctx = modifier.modify_impact(ctx)
	return ctx

static func build_control_context(state: WeatherRuntimeState) -> WeatherControlContext:
	var ctx := WeatherControlContextScript.new()
	for modifier in get_active_modifiers(state):
		ctx = modifier.modify_control(ctx)
	return ctx
