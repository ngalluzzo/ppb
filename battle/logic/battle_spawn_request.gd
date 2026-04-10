class_name BattleSpawnRequest
extends RefCounted

var team: Team
var mobile_def: MobileDefinition
var combatant_id: String = ""
var spawn_position: Vector2 = Vector2.ZERO
var facing_direction: int = 1
var control_source_kind: int = Team.ControlSourceKind.HUMAN

func _init(
	p_team: Team = null,
	p_mobile_def: MobileDefinition = null,
	p_combatant_id: String = "",
	p_spawn_position: Vector2 = Vector2.ZERO,
	p_facing_direction: int = 1,
	p_control_source_kind: int = Team.ControlSourceKind.HUMAN
) -> void:
	team = p_team
	mobile_def = p_mobile_def
	combatant_id = p_combatant_id
	spawn_position = p_spawn_position
	facing_direction = -1 if p_facing_direction < 0 else 1
	control_source_kind = p_control_source_kind
