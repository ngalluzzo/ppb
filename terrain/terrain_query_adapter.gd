class_name TerrainQueryAdapter
extends RefCounted

const GroundHitScript = preload("res://shared/runtime/ground_hit.gd")

var _terrain

func _init(terrain = null) -> void:
	_terrain = terrain

func raycast_ground(world_pos: Vector2, max_drop: float = 2048.0) -> GroundHit:
	if _terrain == null:
		return GroundHitScript.new()
	var space_state = _terrain.get_world_2d().direct_space_state
	if space_state == null:
		return GroundHitScript.new()
	var start := world_pos + Vector2.UP * 8.0
	var target := world_pos + Vector2.DOWN * max_drop
	var query := PhysicsRayQueryParameters2D.create(start, target, _terrain.TERRAIN_COLLISION_MASK)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return GroundHitScript.new(false, world_pos, Vector2.ZERO)
	return GroundHitScript.new(true, result["position"], result.get("normal", Vector2.UP))

func find_grounded_position(world_pos: Vector2, body_size: Vector2, max_drop: float = 2048.0) -> Vector2:
	var hit: GroundHit = raycast_ground(world_pos, max_drop)
	if hit == null or not hit.did_hit:
		return world_pos
	var half_height := body_size.y * 0.5
	return Vector2(world_pos.x, hit.position.y - half_height - 1.0)
