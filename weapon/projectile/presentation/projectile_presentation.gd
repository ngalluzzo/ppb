class_name ProjectilePresentation
extends RefCounted

func setup_definition(
	projectile_body: AnimatedSprite2D,
	projectile_collision_shape: CollisionShape2D,
	detection_collision_shape: CollisionShape2D,
	projectile_def: ProjectileDefinition
) -> void:
	if projectile_def == null:
		return
	if projectile_body != null and projectile_def.sprite_sheet != null:
		var frames: SpriteFrames = SpriteFrames.new()
		frames.add_animation("fly")
		frames.set_animation_loop("fly", true)
		frames.set_animation_speed("fly", projectile_def.animation_speed)
		for frame_index in projectile_def.frame_count:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = projectile_def.sprite_sheet
			atlas.region = Rect2(
				frame_index * projectile_def.frame_size.x,
				0.0,
				projectile_def.frame_size.x,
				projectile_def.frame_size.y
			)
			frames.add_frame("fly", atlas)
		projectile_body.sprite_frames = frames
	if projectile_collision_shape != null and projectile_collision_shape.shape is CircleShape2D:
		(projectile_collision_shape.shape as CircleShape2D).radius = projectile_def.collision_radius
	if detection_collision_shape != null and detection_collision_shape.shape is CircleShape2D:
		(detection_collision_shape.shape as CircleShape2D).radius = projectile_def.collision_radius

func start_flight(projectile_body: AnimatedSprite2D) -> void:
	if projectile_body != null and projectile_body.sprite_frames != null and projectile_body.sprite_frames.has_animation("fly"):
		projectile_body.play("fly")

func apply_runtime_visuals(
	projectile_body: AnimatedSprite2D,
	body_offset: Vector2,
	current_velocity: Vector2,
	body_rotation
) -> void:
	if projectile_body == null:
		return
	projectile_body.position = body_offset
	if body_rotation != null:
		projectile_body.rotation = float(body_rotation)
