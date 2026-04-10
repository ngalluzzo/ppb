class_name ImpactDamageRules
extends RefCounted

static func apply_direct_damage(event: ImpactEvent, context: ImpactResolutionContext) -> void:
	if event == null or event.hit_mobile == null or event.hit_mobile.stat_container == null:
		return
	var multiplier: float = 1.0
	if event.hit_zone == ImpactEvent.HitZone.CORE and event.hit_mobile.mobile_def != null:
		multiplier = event.hit_mobile.mobile_def.core_damage_multiplier
	var damage: float = context.damage if context != null else event.impact_def.damage
	event.hit_mobile.stat_container.take_damage(damage * multiplier)

static func apply_splash_damage(event: ImpactEvent, context: ImpactResolutionContext, units: Array) -> void:
	if event == null:
		return
	var damage: float = context.damage if context != null else event.impact_def.damage
	var radius: float = context.radius if context != null else event.impact_def.radius
	if radius <= 0.0:
		return
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.stat_container == null:
			continue
		var distance: float = unit.global_position.distance_to(event.position)
		if distance > radius:
			continue
		var falloff: float = 1.0 - (distance / radius)
		unit.stat_container.take_damage(damage * falloff)
