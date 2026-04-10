@tool
class_name SidebarContent
extends HSplitContainer

const SectionStackScript = preload("res://ui/system/patterns/section_stack.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _sidebar_root: VBoxContainer
var _content_root: VBoxContainer

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	split_offset = 320
	if _sidebar_root != null:
		return
	_sidebar_root = SectionStackScript.new()
	_sidebar_root.scope = scope
	_sidebar_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_sidebar_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_sidebar_root)
	_content_root = SectionStackScript.new()
	_content_root.scope = scope
	_content_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_content_root)

func get_sidebar_root() -> VBoxContainer:
	_ensure_ui()
	return _sidebar_root

func get_content_root() -> VBoxContainer:
	_ensure_ui()
	return _content_root

