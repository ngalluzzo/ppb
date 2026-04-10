class_name ImpactContextResolver
extends RefCounted

const ImpactResolutionContextScript = preload("res://battle/logic/impact/impact_resolution_context.gd")

static func resolve(event: ImpactEvent, weather_controller = null) -> ImpactResolutionContext:
	if event == null or event.impact_def == null:
		return ImpactResolutionContextScript.new()
	if weather_controller != null:
		var weather_ctx = weather_controller.build_impact_context(event)
		if weather_ctx != null:
			return ImpactResolutionContextScript.new(
				weather_ctx.damage,
				weather_ctx.radius,
				weather_ctx.terrain_drill_power
			)
	return ImpactResolutionContextScript.new(
		event.impact_def.damage,
		event.impact_def.radius,
		event.impact_def.drill_power
	)
