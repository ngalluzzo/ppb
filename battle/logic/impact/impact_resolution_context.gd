class_name ImpactResolutionContext
extends RefCounted

var damage: float = 0.0
var radius: float = 0.0
var terrain_drill_power: float = 0.0

func _init(
	p_damage: float = 0.0,
	p_radius: float = 0.0,
	p_terrain_drill_power: float = 0.0
) -> void:
	damage = p_damage
	radius = p_radius
	terrain_drill_power = p_terrain_drill_power
