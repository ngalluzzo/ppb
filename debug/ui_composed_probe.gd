extends SceneTree

const GalleryScene = preload("res://ui/composed/demo/ui_composed_gallery.tscn")

func _init() -> void:
	print("--- ui composed probe ---")
	var gallery := GalleryScene.instantiate()
	root.add_child(gallery)
	await process_frame

	var previews := gallery.find_children("*", "ExactPreviewPanel", true, false)
	var cards := gallery.find_children("*", "MobileCard", true, false)
	var headers := gallery.find_children("*", "TurnHeader", true, false)
	assert(previews.size() >= 1)
	assert(cards.size() >= 1)
	assert(headers.size() >= 1)

	print("previews=%d cards=%d headers=%d" % [previews.size(), cards.size(), headers.size()])
	gallery.queue_free()
	await process_frame
	quit()

