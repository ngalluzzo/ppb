@tool
class_name ViewportChrome
extends VBoxContainer

const ActionClusterScript = preload("res://ui/system/patterns/action_cluster.gd")
const AppPanelScript = preload("res://ui/system/primitives/app_panel.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _toolbar_root: HBoxContainer
var _viewport_root: AppPanel
var _footer_root: VBoxContainer

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	if _toolbar_root != null:
		return
	_toolbar_root = ActionClusterScript.new()
	_toolbar_root.scope = scope
	add_child(_toolbar_root)
	_viewport_root = AppPanelScript.new()
	_viewport_root.scope = scope
	_viewport_root.variant = "inset"
	_viewport_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_viewport_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_viewport_root)
	_footer_root = VBoxContainer.new()
	_footer_root.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_footer_root)

func get_toolbar_root() -> HBoxContainer:
	_ensure_ui()
	return _toolbar_root

func get_viewport_root() -> AppPanel:
	_ensure_ui()
	return _viewport_root

func get_footer_root() -> VBoxContainer:
	_ensure_ui()
	return _footer_root

