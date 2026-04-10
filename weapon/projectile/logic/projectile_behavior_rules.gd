class_name ProjectileBehaviorRules
extends RefCounted

static func compute_body_offset(
	shot_event: ShotEvent,
	runtime_state: ProjectileRuntimeState,
	projectile_index: int,
	current_velocity: Vector2,
	behavior_context: BehaviorContext,
	raw_progress: float,
	progress: float
) -> Vector2:
	if shot_event == null or shot_event.phase_line == null:
		return Vector2.ZERO
	var behavior: OffsetBehavior = shot_event.phase_line.get_behavior_at(raw_progress)
	if behavior == null:
		return Vector2.ZERO
	var direction: Vector2 = current_velocity.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	behavior_context.progress = progress
	behavior_context.unbounded_progress = raw_progress
	behavior_context.spin_time = runtime_state.spin_time if runtime_state != null else 0.0
	behavior_context.distance_traveled = runtime_state.distance_traveled if runtime_state != null else 0.0
	behavior_context.unit_index = projectile_index
	behavior_context.unit_count = shot_event.projectile_count
	behavior_context.spacing = shot_event.unit_spacing
	behavior_context.perp = Vector2(-direction.y, direction.x)
	return behavior.compute_offset(behavior_context)
