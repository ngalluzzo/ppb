class_name MobileDamageRules
extends RefCounted

static func compute_fall_damage(
	mobile_def: MobileDefinition,
	landing_speed: float,
	weight: float
) -> float:
	if mobile_def == null or landing_speed <= mobile_def.fall_damage_speed_threshold:
		return 0.0
	var safe_weight := maxf(0.1, weight)
	return maxf(
		0.0,
		(
			(landing_speed - mobile_def.fall_damage_speed_threshold)
			* mobile_def.fall_damage_multiplier
			/ safe_weight
		)
	)
