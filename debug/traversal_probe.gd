extends SceneTree

const MobileTraversalScript = preload("res://mobile/logic/mobile_traversal.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mobile_def: MobileDefinition = load("res://roster/mobiles/ironclad/ironclad_mobile_definition.tres")
	var max_walkable_radians: float = MobileTraversalScript.get_max_walkable_slope_radians(mobile_def)

	var test_angles := [0.0, 20.0, 40.0, 41.0, 55.0]
	var results: Array[String] = []
	for angle in test_angles:
		var normal := Vector2.UP.rotated(deg_to_rad(angle))
		results.append("%.1f=%s" % [
			angle,
			"walkable" if MobileTraversalScript.is_surface_walkable(normal, max_walkable_radians) else "blocked"
		])

	print("--- traversal probe ---")
	print("max_walkable_slope_degrees=%s" % mobile_def.max_walkable_slope_degrees)
	print("step_height=%s step_forward_probe=%s" % [mobile_def.step_height, mobile_def.step_forward_probe])
	print("surface_checks=%s" % [", ".join(results)])
	quit()
