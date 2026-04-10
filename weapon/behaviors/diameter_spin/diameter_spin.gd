class_name DiameterSpin
extends OffsetBehavior

@export var spin_rotations: float = 2.0
@export var radius: float = 20.0

func compute_offset(ctx: BehaviorContext) -> Vector2:
	var orbit_progress := ctx.unbounded_progress if continuous else ctx.progress
	var angle = orbit_progress * TAU * spin_rotations
	var r = (ctx.unit_index - 1) * radius
	return Vector2(cos(angle), sin(angle)) * r
	
