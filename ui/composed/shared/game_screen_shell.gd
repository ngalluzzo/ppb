@tool
class_name GameScreenShell
extends Control

const HeaderBodyFooterScript = preload("res://ui/system/patterns/header_body_footer.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

var _recipe: HeaderBodyFooter

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	if _recipe != null:
		return
	AppUIScript.apply_theme(self, AppUIScript.Scope.RUNTIME)
	_recipe = HeaderBodyFooterScript.new()
	_recipe.scope = AppUIScript.Scope.RUNTIME
	_recipe.anchors_preset = PRESET_FULL_RECT
	_recipe.anchor_right = 1.0
	_recipe.anchor_bottom = 1.0
	add_child(_recipe)

func get_header_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_header_root()

func get_body_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_body_root()

func get_footer_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_footer_root()

