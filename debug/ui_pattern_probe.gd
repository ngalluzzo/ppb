extends SceneTree

const GalleryScene = preload("res://ui/system/demo/ui_pattern_gallery.tscn")

func _init() -> void:
	print("--- ui pattern probe ---")
	var gallery := GalleryScene.instantiate()
	root.add_child(gallery)
	await process_frame

	var split_patterns := gallery.find_children("*", "SplitInspectorPreview", true, false)
	var metric_patterns := gallery.find_children("*", "MetricTriplet", true, false)
	assert(split_patterns.size() >= 1)
	assert(metric_patterns.size() >= 1)

	print("split_patterns=%d metric_patterns=%d" % [split_patterns.size(), metric_patterns.size()])
	gallery.queue_free()
	await process_frame
	quit()

