class_name GroundHit
extends RefCounted

var did_hit: bool = false
var position: Vector2 = Vector2.ZERO
var normal: Vector2 = Vector2.ZERO

func _init(
	p_did_hit: bool = false,
	p_position: Vector2 = Vector2.ZERO,
	p_normal: Vector2 = Vector2.ZERO
) -> void:
	did_hit = p_did_hit
	position = p_position
	normal = p_normal
