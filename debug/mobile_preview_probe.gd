extends SceneTree

const MobileScene = preload("res://mobile/mobile.tscn")

func _init() -> void:
	print("--- mobile preview probe ---")

	var mobile := MobileScene.instantiate() as Mobile

	var cannon_def := CannonDefinition.new()
	cannon_def.name = "Probe Mobile Cannon"
	cannon_def.min_angle = 10.0
	cannon_def.max_angle = 80.0
	cannon_def.initial_angle = 35.0
	cannon_def.min_power = 5.0
	cannon_def.max_power = 100.0
	cannon_def.muzzle_offset = Vector2(30.0, 0.0)

	var mobile_def := MobileDefinition.new()
	mobile_def.name = "Probe Mobile"
	mobile_def.cannon_def = cannon_def
	mobile_def.body_size = Vector2(44.0, 52.0)
	mobile_def.body_zone_radius = 28.0
	mobile_def.core_zone_radius = 10.0
	mobile_def.core_zone_offset = Vector2(4.0, -3.0)
	mobile_def.cannon_mount_offset = Vector2(6.0, -14.0)
	mobile_def.max_walkable_slope_degrees = 37.0
	mobile.mobile_def = mobile_def
	mobile.facing_direction = -1

	root.add_child(mobile)
	await process_frame

	var snapshot := mobile.get_debug_snapshot()
	assert(snapshot.has_mobile_definition)
	assert(snapshot.has_cannon)
	assert(snapshot.facing_direction == -1)
	assert(snapshot.body_size == Vector2(44.0, 52.0))
	assert(snapshot.body_zone_radius == 28.0)
	assert(snapshot.core_zone_radius == 10.0)
	assert(snapshot.core_zone_offset == Vector2(4.0, -3.0))
	assert(snapshot.cannon_mount_offset == Vector2(6.0, -14.0))
	assert(snapshot.status_anchor_position.is_equal_approx(Vector2(0.0, -64.8)))
	assert(mobile.cannon.position == Vector2(6.0, -14.0))

	print(
		"body=%s body_zone=%.1f core=%.1f core_offset=%s mount=%s status=%s facing=%d" % [
			snapshot.body_size,
			snapshot.body_zone_radius,
			snapshot.core_zone_radius,
			snapshot.core_zone_offset,
			snapshot.cannon_mount_offset,
			snapshot.status_anchor_position,
			snapshot.facing_direction
		]
	)

	quit()
