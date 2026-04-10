class_name BattleSpawnPlanner
extends RefCounted

const BattleSpawnRequestScript = preload("res://battle/logic/battle_spawn_request.gd")

static func plan_spawns(context: MatchContext, battle_map: BattleMap) -> Array[BattleSpawnRequest]:
	var requests: Array[BattleSpawnRequest] = []
	if context == null or battle_map == null:
		return requests
	var terrain := battle_map.get_terrain()
	if terrain == null:
		push_error("BattleSpawnPlanner: BattleMap has no Terrain node")
		return requests

	for team in context.teams:
		if team == null:
			continue
		var lane := battle_map.get_spawn_lane(team.team_index)
		if lane == null:
			push_error("BattleSpawnPlanner: BattleMap is missing spawn lane for team %d" % team.team_index)
			continue
		for index in team.mobiles.size():
			var mobile_def: MobileDefinition = team.mobiles[index]
			if mobile_def == null:
				continue
			var sampled_spawn: Vector2 = lane.get_spawn_position(terrain)
			var grounded_spawn: Vector2 = terrain.find_grounded_position(sampled_spawn, mobile_def.body_size)
			requests.append(
				BattleSpawnRequestScript.new(
					team,
					mobile_def,
					"team_%d_unit_%d" % [team.team_index, index],
					grounded_spawn,
					lane.facing_direction,
					team.control_source_kind
				)
			)
	return requests
