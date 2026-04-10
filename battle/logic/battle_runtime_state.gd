class_name BattleRuntimeState
extends RefCounted

enum Phase {
	WAITING,
	ACTION,
	RESOLVING,
	TURN_END
}

var context: MatchContext
var active_index: int = 0
var current_phase: int = Phase.WAITING
var projectiles_in_flight: int = 0
var turn_index: int = -1

func _init(
	p_context: MatchContext = null,
	p_active_index: int = 0,
	p_current_phase: int = Phase.WAITING,
	p_projectiles_in_flight: int = 0,
	p_turn_index: int = -1
) -> void:
	context = p_context
	active_index = max(p_active_index, 0)
	current_phase = p_current_phase
	projectiles_in_flight = max(p_projectiles_in_flight, 0)
	turn_index = p_turn_index

func copy() -> BattleRuntimeState:
	return BattleRuntimeState.new(
		context,
		active_index,
		current_phase,
		projectiles_in_flight,
		turn_index
	)
