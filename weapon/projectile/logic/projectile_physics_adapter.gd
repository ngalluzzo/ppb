class_name ProjectilePhysicsAdapter
extends RefCounted

const ProjectileOverlapHitScript = preload("res://shared/runtime/projectile_overlap_hit.gd")
const SurfaceContactScript = preload("res://shared/runtime/surface_contact.gd")

var _move_body_callable: Callable
var _get_slide_collision_count_callable: Callable
var _get_slide_collision_callable: Callable
var _get_overlap_areas_callable: Callable

func _init(
	move_body_callable: Callable = Callable(),
	get_slide_collision_count_callable: Callable = Callable(),
	get_slide_collision_callable: Callable = Callable(),
	get_overlap_areas_callable: Callable = Callable()
) -> void:
	_move_body_callable = move_body_callable
	_get_slide_collision_count_callable = get_slide_collision_count_callable
	_get_slide_collision_callable = get_slide_collision_callable
	_get_overlap_areas_callable = get_overlap_areas_callable

func move_body() -> SurfaceContact:
	if _move_body_callable.is_valid():
		_move_body_callable.call()
	if not _get_slide_collision_count_callable.is_valid() or not _get_slide_collision_callable.is_valid():
		return null
	var collision_count: int = int(_get_slide_collision_count_callable.call())
	if collision_count <= 0:
		return null
	var collision = _get_slide_collision_callable.call(0)
	if collision == null:
		return null
	return SurfaceContactScript.new(collision.get_normal(), collision.get_position(), &"terrain")

func get_overlap_hits() -> Array:
	var hits: Array = []
	if not _get_overlap_areas_callable.is_valid():
		return hits
	var areas = _get_overlap_areas_callable.call()
	for area in areas:
		if area == null:
			continue
		var mobile = area.get_parent().get_parent()
		if mobile == null:
			continue
		var zone: ImpactEvent.HitZone = ImpactEvent.HitZone.NONE
		if area.name == "Core":
			zone = ImpactEvent.HitZone.CORE
		elif area.name == "Body":
			zone = ImpactEvent.HitZone.BODY
		hits.append(ProjectileOverlapHitScript.new(mobile, zone, StringName(area.name)))
	return hits
