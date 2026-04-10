class_name ShotEvent
extends RefCounted

var shot_id: int = 0
var shooter_id: String = ""
var shot_slot: StringName = &"shot_1"
var muzzle_position: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT
var resolved_power: float = 0.0
var base_velocity: Vector2 = Vector2.ZERO
var wind_vector: Vector2 = Vector2.ZERO
var created_frame: int = 0
var projectile_count: int = 0
var stagger_delay: float = 0.0
var unit_spacing: float = 0.0
var max_range: float = 0.0
var gravity: float = 0.0
var power_scale: float = 1.0
var rng_seed: int = 0
var facing_direction: int = 1
var team_index: int = -1
var projectile_definition: ProjectileDefinition
var projectile_definition_path: String = ""
var phase_line: PhaseLine
var phase_line_path: String = ""

func set_runtime_resources(
	p_projectile_definition: ProjectileDefinition,
	p_phase_line: PhaseLine
) -> void:
	projectile_definition = p_projectile_definition
	phase_line = p_phase_line
	projectile_definition_path = (
		p_projectile_definition.resource_path if p_projectile_definition != null else ""
	)
	phase_line_path = p_phase_line.resource_path if p_phase_line != null else ""

func to_dict() -> Dictionary:
	return {
		"shot_id": shot_id,
		"shooter_id": shooter_id,
		"shot_slot": String(shot_slot),
		"muzzle_position": _vector2_to_dict(muzzle_position),
		"aim_direction": _vector2_to_dict(aim_direction),
		"resolved_power": resolved_power,
		"base_velocity": _vector2_to_dict(base_velocity),
		"wind_vector": _vector2_to_dict(wind_vector),
		"created_frame": created_frame,
		"projectile_count": projectile_count,
		"stagger_delay": stagger_delay,
		"unit_spacing": unit_spacing,
		"max_range": max_range,
		"gravity": gravity,
		"power_scale": power_scale,
		"rng_seed": rng_seed,
		"facing_direction": facing_direction,
		"team_index": team_index,
		"projectile_definition_path": projectile_definition_path,
		"phase_line_path": phase_line_path,
	}

static func from_dict(data: Dictionary) -> ShotEvent:
	var event: ShotEvent = ShotEvent.new()
	event.shot_id = int(data.get("shot_id", 0))
	event.shooter_id = data.get("shooter_id", "")
	event.shot_slot = StringName(data.get("shot_slot", "shot_1"))
	event.muzzle_position = _dict_to_vector2(data.get("muzzle_position", {}))
	event.aim_direction = _dict_to_vector2(data.get("aim_direction", {}))
	event.resolved_power = float(data.get("resolved_power", 0.0))
	event.base_velocity = _dict_to_vector2(data.get("base_velocity", {}))
	event.wind_vector = _dict_to_vector2(data.get("wind_vector", {}))
	event.created_frame = int(data.get("created_frame", 0))
	event.projectile_count = int(data.get("projectile_count", 0))
	event.stagger_delay = float(data.get("stagger_delay", 0.0))
	event.unit_spacing = float(data.get("unit_spacing", 0.0))
	event.max_range = float(data.get("max_range", 0.0))
	event.gravity = float(data.get("gravity", 0.0))
	event.power_scale = float(data.get("power_scale", 1.0))
	event.rng_seed = int(data.get("rng_seed", 0))
	event.facing_direction = int(data.get("facing_direction", 1))
	event.team_index = int(data.get("team_index", -1))
	event.projectile_definition_path = data.get("projectile_definition_path", "")
	event.phase_line_path = data.get("phase_line_path", "")
	if event.projectile_definition_path != "":
		event.projectile_definition = load(event.projectile_definition_path) as ProjectileDefinition
	if event.phase_line_path != "":
		event.phase_line = load(event.phase_line_path) as PhaseLine
	return event

static func _vector2_to_dict(value: Vector2) -> Dictionary:
	return {"x": value.x, "y": value.y}

static func _dict_to_vector2(value: Variant) -> Vector2:
	if value is Dictionary:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	return Vector2.ZERO
