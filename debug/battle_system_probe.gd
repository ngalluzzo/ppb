extends SceneTree

const BattleRuntimeStateScript = preload("res://battle/logic/battle_runtime_state.gd")
const BattleTurnRulesScript = preload("res://battle/logic/battle_turn_rules.gd")
const BattleVictoryRulesScript = preload("res://battle/logic/battle_victory_rules.gd")

class FakeMobile:
	extends RefCounted

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var state: BattleRuntimeState = BattleRuntimeStateScript.new()
	state = BattleTurnRulesScript.begin_action_turn(state, 2)
	var start_snapshot := _phase_snapshot(state)

	state = BattleTurnRulesScript.on_shot_submitted(state, 2)
	var resolving_snapshot := _phase_snapshot(state)

	state = BattleTurnRulesScript.on_projectile_resolved(state)
	var mid_resolution_snapshot := _phase_snapshot(state)

	state = BattleTurnRulesScript.on_projectile_resolved(state)
	var turn_end_snapshot := _phase_snapshot(state)

	state = BattleTurnRulesScript.advance_to_next_controller(state, 2)
	var advanced_snapshot := _phase_snapshot(state)

	var win_condition := WinCondition.new()
	var team_a := Team.new(0, "Team A", [])
	var team_b := Team.new(1, "Team B", [])
	var context := MatchContext.new(win_condition, null, [team_a, team_b], null)
	var winning_mobile := FakeMobile.new()
	var result := BattleVictoryRulesScript.evaluate(context, [winning_mobile], {winning_mobile: team_a})

	print("--- battle system probe ---")
	print("turn_flow=%s -> %s -> %s -> %s -> %s" % [
		start_snapshot,
		resolving_snapshot,
		mid_resolution_snapshot,
		turn_end_snapshot,
		advanced_snapshot
	])
	print("victory_winner=%s" % [result.winning_team.team_name if result != null and result.winning_team != null else "none"])
	quit()

func _phase_snapshot(state: BattleRuntimeState) -> Dictionary:
	return {
		"phase": state.current_phase,
		"turn": state.turn_index,
		"active_index": state.active_index,
		"projectiles": state.projectiles_in_flight
	}
