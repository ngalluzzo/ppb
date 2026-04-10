class_name ProjectileCollisionRules
extends RefCounted

static func should_ignore_mobile_overlap(
	mobile,
	shot_event: ShotEvent,
	projectile_def: ProjectileDefinition,
	distance_traveled: float
) -> bool:
	if mobile == null or shot_event == null:
		return false
	if mobile.combatant_id != shot_event.shooter_id:
		return false
	var clearance_distance: float = 48.0
	if projectile_def != null:
		clearance_distance = maxf(clearance_distance, projectile_def.collision_radius * 4.0)
	return distance_traveled < clearance_distance

static func resolve_hit_zone(area_name: StringName) -> ImpactEvent.HitZone:
	if area_name == &"Core":
		return ImpactEvent.HitZone.CORE
	if area_name == &"Body":
		return ImpactEvent.HitZone.BODY
	return ImpactEvent.HitZone.NONE
