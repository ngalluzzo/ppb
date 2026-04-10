extends SceneTree

const OverlayScene = preload("res://battle/hud/battle_overlay.tscn")

func _init() -> void:
	print("--- battle overlay probe ---")
	var overlay := OverlayScene.instantiate()
	root.add_child(overlay)
	await process_frame

	var turn_headers := overlay.find_children("*", "TurnHeader", true, false)
	var fire_clusters := overlay.find_children("*", "FireControlCluster", true, false)
	var weather_strips := overlay.find_children("*", "WindWeatherStrip", true, false)
	assert(turn_headers.size() == 1)
	assert(fire_clusters.size() == 1)
	assert(weather_strips.size() == 1)

	print("turn_headers=%d fire_clusters=%d weather_strips=%d" % [
		turn_headers.size(),
		fire_clusters.size(),
		weather_strips.size(),
	])
	overlay.queue_free()
	await process_frame
	quit()

