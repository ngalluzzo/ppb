class_name ImpactTerrainRules
extends RefCounted

static func apply_terrain_damage(event: ImpactEvent, context: ImpactResolutionContext, terrain) -> void:
	if event == null or event.impact_def == null or terrain == null or terrain.tile_set == null:
		return
	var tile_size: Vector2i = terrain.tile_set.tile_size
	if tile_size.x <= 0:
		return
	var radius: float = context.radius if context != null else event.impact_def.radius
	var radius_in_tiles: int = int(radius / tile_size.x)
	var center_tile: Vector2i = terrain.local_to_map(terrain.to_local(event.position))
	var remaining_drill: float = context.terrain_drill_power if context != null else event.impact_def.drill_power

	for x in range(-radius_in_tiles, radius_in_tiles + 1):
		for y in range(-radius_in_tiles, radius_in_tiles + 1):
			if Vector2(x, y).length() > radius_in_tiles:
				continue
			var tile_pos: Vector2i = center_tile + Vector2i(x, y)
			var tile_def = terrain.get_tile_definition(tile_pos)
			if tile_def == null:
				continue
			if remaining_drill < tile_def.projectile_resistance:
				continue
			remaining_drill -= tile_def.projectile_resistance
			terrain.degrade_tile(tile_pos, event.position)
