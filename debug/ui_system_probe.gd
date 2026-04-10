extends SceneTree

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const AppTheme = preload("res://ui/system/theme/app_theme.tres")
const EditorTheme = preload("res://ui/system/theme/editor_theme.tres")
const RuntimeTokens = preload("res://ui/system/theme/app_ui_tokens.tres")
const EditorTokens = preload("res://ui/system/theme/editor_ui_tokens.tres")
const GalleryScene = preload("res://ui/system/demo/ui_system_gallery.tscn")

func _init() -> void:
	print("--- ui system probe ---")
	assert(AppTheme != null)
	assert(EditorTheme != null)
	assert(RuntimeTokens != null)
	assert(EditorTokens != null)
	assert(AppUIScript.get_theme(AppUIScript.Scope.RUNTIME) != null)
	assert(AppUIScript.get_theme(AppUIScript.Scope.EDITOR) != null)
	assert(AppUIScript.get_tokens(AppUIScript.Scope.RUNTIME).get_color(&"panel").a > 0.0)

	var gallery := GalleryScene.instantiate() as Control
	root.add_child(gallery)
	await process_frame
	assert(gallery.get_child_count() >= 1)

	print(
		"runtime_title=%d editor_panel=%s children=%d" % [
			AppUIScript.font_size(&"title", AppUIScript.Scope.RUNTIME),
			AppUIScript.color(&"panel", AppUIScript.Scope.EDITOR),
			gallery.get_child_count()
		]
	)
	quit()
