extends SceneTree

const WeatherControllerScript = preload("res://battle/weather/weather_controller.gd")
const ShotEventScript = preload("res://weapon/shot/shot_event.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var config: Resource = load("res://roster/weather/match_weather_default.tres")
	var seed := 424242
	var snapshot_a := _collect_snapshot(config, seed)
	var snapshot_b := _collect_snapshot(config, seed)
	var same_seed_matches := snapshot_a == snapshot_b

	var controller = WeatherControllerScript.new()
	root.add_child(controller)
	controller.setup(config, seed)
	controller.on_turn_started(0)

	var shot_event = ShotEventScript.new()
	shot_event.base_velocity = Vector2(100.0, -40.0)
	shot_event.gravity = 98.0
	shot_event.aim_direction = Vector2(1.0, -0.4).normalized()
	var ballistics_ctx = controller.build_ballistics_context(shot_event)

	print("--- weather probe ---")
	print("same_seed_matches=%s" % same_seed_matches)
	print("turn_snapshots=%s" % JSON.stringify(snapshot_a))
	print(
		"ballistics velocity=%s gravity=%s wind=%s active=%s" % [
			ballistics_ctx.base_velocity,
			ballistics_ctx.gravity,
			ballistics_ctx.wind_vector,
			_active_name(controller.get_weather_state())
		]
	)

	controller.queue_free()
	quit()

func _collect_snapshot(config: Resource, seed: int) -> Array:
	var controller = WeatherControllerScript.new()
	root.add_child(controller)
	controller.setup(config, seed)
	var rows: Array = []
	rows.append(_state_row(controller.get_weather_state()))
	for turn_index in range(6):
		controller.on_turn_started(turn_index)
		rows.append(_state_row(controller.get_weather_state()))
	controller.queue_free()
	return rows

func _state_row(state) -> Dictionary:
	var forecast: Array[String] = []
	for entry in state.forecast:
		if entry == null or entry.definition == null:
			continue
		forecast.append(entry.definition.display_name)
	return {
		"turn": state.turn_index,
		"wind": [state.wind_vector.x, state.wind_vector.y],
		"active": _active_name(state),
		"forecast": forecast,
	}

func _active_name(state) -> String:
	if state == null or state.active_event == null or state.active_event.definition == null:
		return "clear"
	return state.active_event.definition.display_name
