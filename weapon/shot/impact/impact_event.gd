class_name ImpactEvent
extends RefCounted

enum HitZone {
	NONE,
	BODY,
	CORE
}

var position: Vector2
var normal: Vector2
var impact_def: ImpactDefinition
var hit_tile: TileDefinition
var hit_zone: HitZone = HitZone.NONE
var hit_mobile
var shot_id: int = 0
var projectile_index: int = -1
var shooter_id: String = ""
var team_index: int = -1

func _init(
	p: Vector2 = Vector2.ZERO,
	n: Vector2 = Vector2.ZERO,
	def: ImpactDefinition = null,
	p_shot_id: int = 0,
	p_projectile_index: int = -1,
	p_shooter_id: String = "",
	p_team_index: int = -1,
	p_hit_zone: HitZone = HitZone.NONE,
	p_hit_mobile = null
) -> void:
	position = p
	normal = n
	impact_def = def
	shot_id = p_shot_id
	projectile_index = p_projectile_index
	shooter_id = p_shooter_id
	team_index = p_team_index
	hit_zone = p_hit_zone
	hit_mobile = p_hit_mobile
