class_name SurfaceContact
extends RefCounted

var normal: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
var collider_kind: StringName = &""

func _init(
	p_normal: Vector2 = Vector2.ZERO,
	p_position: Vector2 = Vector2.ZERO,
	p_collider_kind: StringName = &""
) -> void:
	normal = p_normal
	position = p_position
	collider_kind = p_collider_kind
