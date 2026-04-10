class_name ImpactStatusRules
extends RefCounted

static func apply_impact_statuses(
	event: ImpactEvent,
	context: ImpactResolutionContext,
	battle_system,
	weather_controller = null
) -> void:
	if event == null or battle_system == null or weather_controller == null:
		return
	var radius: float = context.radius if context != null else event.impact_def.radius
	var applications: Array = weather_controller.build_impact_status_applications(event, battle_system, radius)
	for application in applications:
		if application == null or application.target_mobile == null:
			continue
		var mobile = application.target_mobile
		if mobile == null or not is_instance_valid(mobile) or mobile.status_controller == null:
			continue
		mobile.status_controller.apply_status(application)
