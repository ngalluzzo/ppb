@tool
class_name SplitInspectorPreview
extends HSplitContainer

const SectionStackScript = preload("res://ui/system/patterns/section_stack.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _inspector_root: VBoxContainer
var _preview_root: VBoxContainer

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	split_offset = 380
	if _inspector_root != null:
		return
	_inspector_root = SectionStackScript.new()
	_inspector_root.scope = scope
	_inspector_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_inspector_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_inspector_root)
	_preview_root = SectionStackScript.new()
	_preview_root.scope = scope
	_preview_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_preview_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_preview_root)

func get_inspector_root() -> VBoxContainer:
	_ensure_ui()
	return _inspector_root

func get_preview_root() -> VBoxContainer:
	_ensure_ui()
	return _preview_root

