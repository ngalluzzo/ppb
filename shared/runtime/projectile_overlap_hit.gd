class_name ProjectileOverlapHit
extends RefCounted

var mobile
var zone: ImpactEvent.HitZone = ImpactEvent.HitZone.NONE
var source_area_name: StringName = &""

func _init(
	p_mobile = null,
	p_zone: ImpactEvent.HitZone = ImpactEvent.HitZone.NONE,
	p_source_area_name: StringName = &""
) -> void:
	mobile = p_mobile
	zone = p_zone
	source_area_name = p_source_area_name
