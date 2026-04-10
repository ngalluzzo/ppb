@tool
class_name ShotPreviewBoundaries
extends Node2D

const FLOOR_NAME := "__PreviewFloor"
const WALL_NAME := "__PreviewWall"

func configure(bounds: Rect2, floor_y: float, wall_x: float) -> void:
	_ensure_body(FLOOR_NAME, Vector2(bounds.position.x + bounds.size.x * 0.5, floor_y + 32.0), Vector2(bounds.size.x + 256.0, 64.0))
	_ensure_body(WALL_NAME, Vector2(wall_x + 32.0, bounds.position.y + bounds.size.y * 0.5), Vector2(64.0, bounds.size.y + 256.0))

func clear_bodies() -> void:
	for child in get_children():
		child.queue_free()

func _ensure_body(body_name: String, body_position: Vector2, shape_size: Vector2) -> void:
	var body := get_node_or_null(body_name) as StaticBody2D
	if body == null:
		body = StaticBody2D.new()
		body.name = body_name
		add_child(body)
		var collision := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		collision.shape = rect
		body.add_child(collision)
	body.position = body_position
	body.collision_layer = 1
	body.collision_mask = 1
	var shape := (body.get_child(0) as CollisionShape2D).shape as RectangleShape2D
	shape.size = shape_size
