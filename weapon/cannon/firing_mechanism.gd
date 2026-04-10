class_name FiringMechanism
extends Node

const ShotShooterContextScript = preload("res://weapon/shot/shot_shooter_context.gd")

static var _next_shot_id_counter: int = 1

var cannon: Cannon
var cannon_def: CannonDefinition
var active_shot_pattern: ShotPattern
var active_shot_slot: StringName = &"shot_1"

var _resolver: ShotResolver = ShotResolver.new()

func setup(
	p_cannon: Cannon,
	p_cannon_def: CannonDefinition,
	p_shot_pattern: ShotPattern,
	p_shot_slot: StringName = &"shot_1"
) -> void:
	cannon = p_cannon
	cannon_def = p_cannon_def
	set_active_shot_pattern(p_shot_pattern, p_shot_slot)

func set_active_shot_pattern(pattern: ShotPattern, slot: StringName = &"shot_1") -> void:
	active_shot_pattern = pattern
	active_shot_slot = slot

func get_active_shot_slot() -> StringName:
	return active_shot_slot

func get_active_shot_pattern() -> ShotPattern:
	return active_shot_pattern

func can_fire() -> bool:
	return active_shot_pattern != null and cannon != null and cannon_def != null

func submit_fire_command(
	command: FireCommand,
	shooter: Mobile,
	weather_controller = null
) -> ShotEvent:
	if command == null or shooter == null:
		return null
	if active_shot_pattern == null or cannon == null or cannon_def == null:
		return null
	var shooter_context = ShotShooterContextScript.new(
		shooter.combatant_id,
		shooter.team_index,
		shooter.facing_direction
	)
	var event: ShotEvent = _resolver.resolve(
		command,
		shooter_context,
		cannon,
		active_shot_pattern,
		_consume_next_shot_id(),
		weather_controller
	)
	return event

func _consume_next_shot_id() -> int:
	var shot_id: int = _next_shot_id_counter
	_next_shot_id_counter += 1
	return shot_id
