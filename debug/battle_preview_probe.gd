extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle_system := BattleSystem.new()
	root.add_child(battle_system)
	await process_frame

	var weather_config = load("res://roster/weather/match_weather_default.tres")
	battle_system.begin_editor_preview("Probe Preview", weather_config, 7)
	var preview_snapshot: Dictionary = battle_system.get_preview_debug_snapshot()

	print("--- battle preview probe ---")
	print("preview active=%s phase=%s weather=%s root=%s" % [
		preview_snapshot.active,
		preview_snapshot.phase,
		preview_snapshot.weather_name,
		preview_snapshot.world_root
	])

	battle_system.end_editor_preview()
	var ended_snapshot: Dictionary = battle_system.get_preview_debug_snapshot()
	print("preview ended=%s phase=%s weather=%s" % [
		ended_snapshot.active,
		ended_snapshot.phase,
		ended_snapshot.weather_name
	])

	battle_system.queue_free()
	quit()
