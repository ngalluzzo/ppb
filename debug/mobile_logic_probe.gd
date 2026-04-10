extends SceneTree

const MobileDamageRules = preload("res://mobile/logic/mobile_damage_rules.gd")
const MobileLocomotion = preload("res://mobile/logic/mobile_locomotion.gd")
const MobilePhysicsStateScript = preload("res://mobile/logic/mobile_physics_state.gd")
const MobileTraversal = preload("res://mobile/logic/mobile_traversal.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mobile_def: MobileDefinition = load("res://roster/mobiles/ironclad/ironclad_mobile_definition.tres")
	var idle_state: MobilePhysicsState = MobilePhysicsStateScript.new(Vector2.ZERO, true, false, 1, true)
	var moving_state: MobilePhysicsState = MobilePhysicsStateScript.new(Vector2(60.0, 0.0), true, true, 1, true)
	var walkable_40 := MobileTraversal.is_surface_walkable(Vector2.UP.rotated(deg_to_rad(40.0)), MobileTraversal.get_max_walkable_slope_radians(mobile_def))
	var blocked_55 := MobileTraversal.is_surface_walkable(Vector2.UP.rotated(deg_to_rad(55.0)), MobileTraversal.get_max_walkable_slope_radians(mobile_def))
	var can_step_idle := MobileTraversal.can_attempt_step_up(idle_state, mobile_def, 1, 50.0, 1.0 / 60.0)
	var can_step_moving := MobileTraversal.can_attempt_step_up(moving_state, mobile_def, 1, 50.0, 1.0 / 60.0)
	var fall_damage := MobileDamageRules.compute_fall_damage(mobile_def, 600.0, 1.0)
	var thrust_spend := MobileLocomotion.compute_horizontal_spend(100.0, 1, true, 10.0, 17.5)

	print("--- mobile logic probe ---")
	print("walkable_40=%s blocked_55=%s can_step_idle=%s can_step_moving=%s" % [walkable_40, blocked_55, can_step_idle, can_step_moving])
	print("fall_damage_600=%s thrust_spend=%s" % [fall_damage, thrust_spend])
	quit()
