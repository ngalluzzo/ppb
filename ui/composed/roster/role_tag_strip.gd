@tool
class_name RoleTagStrip
extends HBoxContainer

const AppBadgeScript = preload("res://ui/system/primitives/app_badge.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))

func set_tags(tags: Array[String]) -> void:
	for child in get_children():
		child.queue_free()
	for tag in tags:
		var badge := AppBadgeScript.new()
		badge.scope = scope
		badge.variant = "info"
		badge.text_value = tag
		add_child(badge)

