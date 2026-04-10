@tool
class_name AppLabel
extends Label

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

@export_enum("caption", "body", "label", "section", "title", "display") var role: String = "body":
	set(value):
		role = value
		_apply_style()

@export_enum("primary", "muted", "accent", "danger", "success", "warning") var text_role: String = "primary":
	set(value):
		text_role = value
		_apply_style()

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	AppUIScript.configure_text_control(self, StringName(role), StringName(text_role), scope)
