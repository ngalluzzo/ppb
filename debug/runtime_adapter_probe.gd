extends SceneTree

const FloorContactStateScript = preload("res://shared/runtime/floor_contact_state.gd")
const MobilePhysicsAdapterScript = preload("res://mobile/logic/mobile_physics_adapter.gd")
const ProjectilePhysicsAdapterScript = preload("res://weapon/projectile/logic/projectile_physics_adapter.gd")
const TerrainQueryAdapterScript = preload("res://terrain/terrain_query_adapter.gd")

class FakeCollision:
	extends RefCounted
	var _normal: Vector2
	var _position: Vector2

	func _init(p_normal: Vector2, p_position: Vector2) -> void:
		_normal = p_normal
		_position = p_position

	func get_normal() -> Vector2:
		return _normal

	func get_position() -> Vector2:
		return _position

class FakeNode:
	extends RefCounted
	var _parent

	func _init(parent_ref = null) -> void:
		_parent = parent_ref

	func get_parent():
		return _parent

class FakeMobile:
	extends RefCounted
	var combatant_id: String = ""

	func _init(p_combatant_id: String = "") -> void:
		combatant_id = p_combatant_id

class FakeArea:
	extends RefCounted
	var name: StringName = &""
	var _parent

	func _init(p_name: StringName, p_parent) -> void:
		name = p_name
		_parent = p_parent

	func get_parent():
		return _parent

class FakeTerrain:
	extends RefCounted
	const TERRAIN_COLLISION_MASK := 1

	class FakeWorld:
		extends RefCounted
		var direct_space_state

	class FakeSpaceState:
		extends RefCounted
		func intersect_ray(_query) -> Dictionary:
			return {
				"position": Vector2(32.0, 96.0),
				"normal": Vector2.UP,
			}

	func get_world_2d():
		var world := FakeWorld.new()
		world.direct_space_state = FakeSpaceState.new()
		return world

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var floor_adapter = MobilePhysicsAdapterScript.new(
		func(_transform, _motion, collision = null, _margin = 0.08, _recovery = true):
			if collision != null:
				return false
			return false,
		func(): pass,
		func(): pass,
		func():
			return FloorContactStateScript.new(true, Vector2.UP, 0.0)
	)

	var probe_mobile := FakeMobile.new("adapter_probe")
	var parent_node := FakeNode.new(probe_mobile)
	var projectile_adapter = ProjectilePhysicsAdapterScript.new(
		func(): pass,
		func(): return 1,
		func(_index): return FakeCollision.new(Vector2.LEFT, Vector2(12.0, 6.0)),
		func():
			return [FakeArea.new(&"Core", parent_node)]
	)

	var terrain_adapter = TerrainQueryAdapterScript.new(FakeTerrain.new())
	var floor_contact = floor_adapter.get_floor_contact_state()
	var terrain_contact = projectile_adapter.move_body()
	var overlap_hits: Array = projectile_adapter.get_overlap_hits()
	var ground_hit = terrain_adapter.raycast_ground(Vector2(32.0, 0.0), 128.0)

	print("--- runtime adapter probe ---")
	print("floor_contact grounded=%s normal=%s angle=%.2f" % [
		floor_contact.grounded,
		floor_contact.floor_normal,
		floor_contact.floor_angle
	])
	print("terrain_contact normal=%s position=%s kind=%s" % [
		terrain_contact.normal,
		terrain_contact.position,
		String(terrain_contact.collider_kind)
	])
	print("overlap_hits count=%s first_zone=%s first_mobile=%s" % [
		overlap_hits.size(),
		overlap_hits[0].zone if not overlap_hits.is_empty() else -1,
		overlap_hits[0].mobile.combatant_id if not overlap_hits.is_empty() and overlap_hits[0].mobile != null else ""
	])
	print("ground_hit did_hit=%s position=%s normal=%s" % [
		ground_hit.did_hit,
		ground_hit.position,
		ground_hit.normal
	])

	quit()
