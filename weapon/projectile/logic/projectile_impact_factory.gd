class_name ProjectileImpactFactory
extends RefCounted

static func build_terrain_impact(
	position: Vector2,
	normal: Vector2,
	projectile_def: ProjectileDefinition,
	shot_id: int,
	projectile_index: int,
	shot_event: ShotEvent
) -> ImpactEvent:
	return ImpactEvent.new(
		position,
		normal,
		projectile_def.impact_def if projectile_def != null else null,
		shot_id,
		projectile_index,
		shot_event.shooter_id if shot_event != null else "",
		shot_event.team_index if shot_event != null else -1,
		ImpactEvent.HitZone.NONE
	)

static func build_mobile_impact(
	position: Vector2,
	projectile_def: ProjectileDefinition,
	shot_id: int,
	projectile_index: int,
	shot_event: ShotEvent,
	mobile,
	zone: ImpactEvent.HitZone
) -> ImpactEvent:
	return ImpactEvent.new(
		position,
		Vector2.ZERO,
		projectile_def.impact_def if projectile_def != null else null,
		shot_id,
		projectile_index,
		shot_event.shooter_id if shot_event != null else "",
		shot_event.team_index if shot_event != null else -1,
		zone,
		mobile
	)
