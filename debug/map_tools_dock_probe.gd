extends SceneTree

const TerrainAuthoringDockScript = preload("res://addons/map_tools/terrain_authoring_dock.gd")

func _init() -> void:
	print("--- map tools dock probe ---")
	var dock := TerrainAuthoringDockScript.new()
	root.add_child(dock)
	await process_frame

	assert(dock.get_child_count() > 0)
	var tabs := dock.find_children("*", "TabContainer", true, false)
	assert(tabs.size() >= 1)
	var panels := dock.find_children("*", "ValidationListPanel", true, false)
	assert(panels.size() >= 1)

	print("children=%d tabs=%d validation_panels=%d" % [dock.get_child_count(), tabs.size(), panels.size()])
	dock.queue_free()
	await process_frame
	quit()
