class_name ProjectileDefinition
extends Resource

@export var name: String = "unnamed"
@export var impact_def: ImpactDefinition
@export var sprite_sheet: Texture2D
@export var frame_size: Vector2i = Vector2i(16, 16)
@export var frame_count: int = 4
@export var animation_speed: float = 8.0
@export var collision_radius: float = 8.0
