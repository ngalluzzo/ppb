@tool
class_name ToolWorkspaceShell
extends VBoxContainer

const ToolDockShellScript = preload("res://ui/system/blocks/tool_dock_shell.gd")
const ToolbarBodyStatusScript = preload("res://ui/system/patterns/toolbar_body_status.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _shell: ToolDockShell
var _recipe: ToolbarBodyStatus

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	if _shell != null:
		return
	_shell = ToolDockShellScript.new()
	_shell.scope = scope
	add_child(_shell)
	_recipe = ToolbarBodyStatusScript.new()
	_recipe.scope = scope
	_shell.get_content_root().add_child(_recipe)

func set_title_text(text: String) -> void:
	_ensure_ui()
	_shell.set_title_text(text)

func set_help_text(text: String) -> void:
	_ensure_ui()
	_shell.set_help_text(text)

func get_toolbar_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_toolbar_root()

func get_body_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_body_root()

func get_status_root() -> VBoxContainer:
	_ensure_ui()
	return _recipe.get_status_root()

