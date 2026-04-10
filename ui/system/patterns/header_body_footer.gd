@tool
class_name HeaderBodyFooter
extends VBoxContainer

const SectionStackScript = preload("res://ui/system/patterns/section_stack.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _header_root: VBoxContainer
var _body_root: VBoxContainer
var _footer_root: VBoxContainer

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	if _header_root != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"md", scope))
	_header_root = SectionStackScript.new()
	_header_root.scope = scope
	add_child(_header_root)
	_body_root = SectionStackScript.new()
	_body_root.scope = scope
	_body_root.size_flags_horizontal = SIZE_EXPAND_FILL
	_body_root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_body_root)
	_footer_root = SectionStackScript.new()
	_footer_root.scope = scope
	_footer_root.compact = true
	add_child(_footer_root)

func get_header_root() -> VBoxContainer:
	_ensure_ui()
	return _header_root

func get_body_root() -> VBoxContainer:
	_ensure_ui()
	return _body_root

func get_footer_root() -> VBoxContainer:
	_ensure_ui()
	return _footer_root

