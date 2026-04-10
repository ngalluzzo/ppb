@tool
class_name AppIcon
extends TextureRect

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

@export_enum("sm", "md", "lg") var size_role: String = "md":
	set(value):
		size_role = value
		_apply_style()

@export_enum("primary", "muted", "accent", "danger", "success", "warning") var tint_role: String = "primary":
	set(value):
		tint_role = value
		_apply_style()

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	var icon_size := AppUIScript.icon_size(StringName(size_role), scope)
	custom_minimum_size = Vector2(icon_size, icon_size)
	modulate = AppUIScript.color(StringName(tint_role), scope)
