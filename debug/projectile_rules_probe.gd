extends SceneTree

const ProjectileBehaviorRulesScript = preload("res://weapon/projectile/logic/projectile_behavior_rules.gd")
const ProjectileCollisionRulesScript = preload("res://weapon/projectile/logic/projectile_collision_rules.gd")
const ProjectileImpactFactoryScript = preload("res://weapon/projectile/logic/projectile_impact_factory.gd")
const ProjectileMotionRulesScript = preload("res://weapon/projectile/logic/projectile_motion_rules.gd")
const ProjectileRuntimeStateScript = preload("res://weapon/projectile/logic/projectile_runtime_state.gd")

class FakeMobile:
	extends RefCounted
	var combatant_id: String = ""

	func _init(p_combatant_id: String = "") -> void:
		combatant_id = p_combatant_id

class ProbeBehavior:
	extends OffsetBehavior

	func compute_offset(ctx: BehaviorContext) -> Vector2:
		return ctx.perp * (ctx.spacing * 0.5)

func _init() -> void:
	call_deferred("_run")

func _make_probe_mobile(combatant_id: String):
	return FakeMobile.new(combatant_id)

func _run() -> void:
	var projectile_def := ProjectileDefinition.new()
	projectile_def.impact_def = ImpactDefinition.new()
	projectile_def.collision_radius = 8.0

	var shot_event := ShotEvent.new()
	shot_event.shot_id = 9
	shot_event.shooter_id = "shooter_a"
	shot_event.team_index = 2
	shot_event.gravity = 10.0
	shot_event.wind_vector = Vector2(4.0, 0.0)
	shot_event.max_range = 100.0
	shot_event.projectile_count = 2
	shot_event.unit_spacing = 20.0
	shot_event.phase_line = PhaseLine.new()
	var phase_entry := PhaseEntry.new()
	phase_entry.duration = 1.0
	phase_entry.behavior = ProbeBehavior.new()
	shot_event.phase_line.phases = [phase_entry]

	var state = ProjectileRuntimeStateScript.new(0.0, 0.0, Vector2.ZERO, Vector2.ZERO)
	var begin_frame: Dictionary = ProjectileMotionRulesScript.begin_frame(
		state,
		Vector2(10.0, -5.0),
		shot_event,
		0.5
	)
	var next_state = begin_frame["state"]
	var next_velocity: Vector2 = begin_frame["velocity"]
	var finish_frame: Dictionary = ProjectileMotionRulesScript.finish_frame(next_state, Vector2(12.0, -3.0), shot_event)
	var finished_state = finish_frame["state"]
	var behavior_context := BehaviorContext.new()
	var body_offset: Vector2 = ProjectileBehaviorRulesScript.compute_body_offset(
		shot_event,
		finished_state,
		1,
		next_velocity,
		behavior_context,
		finish_frame["raw_progress"],
		finish_frame["progress"]
	)

	var shooter_mobile = _make_probe_mobile("shooter_a")
	var target_mobile = _make_probe_mobile("target_b")
	var ignored_overlap: bool = ProjectileCollisionRulesScript.should_ignore_mobile_overlap(
		shooter_mobile,
		shot_event,
		projectile_def,
		10.0
	)
	var allowed_overlap: bool = ProjectileCollisionRulesScript.should_ignore_mobile_overlap(
		target_mobile,
		shot_event,
		projectile_def,
		10.0
	)

	var terrain_impact: ImpactEvent = ProjectileImpactFactoryScript.build_terrain_impact(
		Vector2(5.0, 6.0),
		Vector2.UP,
		projectile_def,
		shot_event.shot_id,
		1,
		shot_event
	)
	var mobile_impact: ImpactEvent = ProjectileImpactFactoryScript.build_mobile_impact(
		Vector2(7.0, 8.0),
		projectile_def,
		shot_event.shot_id,
		1,
		shot_event,
		target_mobile,
		ImpactEvent.HitZone.CORE
	)

	print("--- projectile rules probe ---")
	print("motion velocity=%s spin=%.2f distance=%.2f raw=%.2f progress=%.2f" % [
		next_velocity,
		finished_state.spin_time,
		finished_state.distance_traveled,
		finish_frame["raw_progress"],
		finish_frame["progress"]
	])
	print("collision ignore_shooter=%s ignore_target=%s zone_core=%s" % [
		ignored_overlap,
		allowed_overlap,
		ProjectileCollisionRulesScript.resolve_hit_zone(&"Core")
	])
	print("impacts terrain=(%s,%s,%s) mobile=(%s,%s,%s) offset=%s" % [
		terrain_impact.position,
		terrain_impact.normal,
		terrain_impact.hit_zone,
		mobile_impact.position,
		mobile_impact.hit_mobile.combatant_id,
		mobile_impact.hit_zone,
		body_offset
	])

	quit()
