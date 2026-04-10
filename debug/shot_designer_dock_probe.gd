extends SceneTree

const ShotDesignerDockScript = preload("res://addons/shot_designer/shot_designer_dock.gd")

func _init() -> void:
	print("--- shot designer dock probe ---")
	var dock := ShotDesignerDockScript.new()
	root.add_child(dock)
	await process_frame

	assert(dock.get_child_count() > 0)
	var viewports := dock.find_children("*", "ShotPreviewViewport", true, false)
	assert(viewports.size() == 1)
	var viewport := viewports[0]

	print("children=%d viewport=%s" % [dock.get_child_count(), viewport.name if viewport != null else "none"])
	dock.queue_free()
	await process_frame
	quit()
