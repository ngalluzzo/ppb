extends SceneTree

const TitleScene = preload("res://ui/title/title_screen.tscn")

func _init() -> void:
	print("--- title shell probe ---")
	var title := TitleScene.instantiate()
	root.add_child(title)
	await process_frame

	var hero_stacks := title.find_children("*", "HeroTitleStack", true, false)
	var menu_rails := title.find_children("*", "TitleMenuRail", true, false)
	var footers := title.find_children("*", "AmbientInfoFooter", true, false)
	assert(hero_stacks.size() == 1)
	assert(menu_rails.size() == 1)
	assert(footers.size() == 1)

	print("hero_stacks=%d menu_rails=%d footers=%d" % [
		hero_stacks.size(),
		menu_rails.size(),
		footers.size(),
	])
	title.queue_free()
	await process_frame
	quit()

