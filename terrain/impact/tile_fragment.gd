class_name TileFragment
extends Sprite2D

var velocity: Vector2
var angular_vel: float
var lifetime: float = 0.6
var elapsed: float = 0.0
const GRAVITY = 420.0

func setup(tile_texture: Texture2D, region: Rect2, world_pos: Vector2, direction: Vector2) -> void:
	texture = tile_texture
	region_enabled = true
	region_rect = region
	position = world_pos
	velocity = direction * randf_range(60.0, 140.0)
	angular_vel = randf_range(-5.0, 5.0)

func _process(delta: float) -> void:
	elapsed += delta
	velocity.y += GRAVITY * delta
	position += velocity * delta
	rotation += angular_vel * delta
	modulate.a = 1.0 - (elapsed / lifetime)
	if elapsed >= lifetime:
		queue_free()
