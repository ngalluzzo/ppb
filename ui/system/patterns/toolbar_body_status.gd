@tool
class_name ToolbarBodyStatus
extends VBoxContainer

const HeaderBodyFooterScript = preload("res://ui/system/patterns/header_body_footer.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _recipe: HeaderBodyFooter

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	if _recipe != null:
		return
	_recipe = HeaderBodyFooterScript.new()
	_recipe.scope = scope
	add_child(_recipe)

func get_toolbar_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_header_root()

func get_body_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_body_root()

func get_status_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_footer_root()

