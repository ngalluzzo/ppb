@tool
class_name LinkedResourceSection
extends VBoxContainer

const InspectorSectionScript = preload("res://ui/system/blocks/inspector_section.gd")
const DirtyStateChipScript = preload("res://ui/system/blocks/dirty_state_chip.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _header: HBoxContainer
var _section: InspectorSection
var _chip: DirtyStateChip

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _section != null:
		return
	_header = HBoxContainer.new()
	_header.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_header)
	_section = InspectorSectionScript.new()
	_section.scope = scope
	add_child(_section)
	_chip = DirtyStateChipScript.new()
	_chip.scope = scope
	_header.add_child(_chip)

func set_title_text(text: String) -> void:
	_ensure_ui()
	_section.set_title_text(text)

func set_path_text(text: String) -> void:
	_ensure_ui()
	_section.set_path_text(text)

func set_dirty_state(state: StringName) -> void:
	_ensure_ui()
	_chip.set_state(state)

func get_content_root() -> VBoxContainer:
	_ensure_ui()
	return _section.get_content_root()

