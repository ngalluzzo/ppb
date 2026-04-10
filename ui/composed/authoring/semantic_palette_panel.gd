@tool
class_name SemanticPalettePanel
extends VBoxContainer

const PreviewPanelScript = preload("res://ui/system/blocks/preview_panel.gd")
const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _panel: PreviewPanel
var _list: ItemList
var _status: StatusCallout

func _ready() -> void:
	if _panel != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_panel = PreviewPanelScript.new()
	_panel.scope = scope
	_panel.set_title_text("Semantic Palette")
	add_child(_panel)
	_list = ItemList.new()
	_list.fixed_icon_size = Vector2i(48, 48)
	_list.max_columns = 3
	_list.same_column_width = true
	_list.size_flags_horizontal = SIZE_EXPAND_FILL
	_list.size_flags_vertical = SIZE_EXPAND_FILL
	_panel.get_content_root().add_child(_list)
	_status = StatusCalloutScript.new()
	_status.scope = scope
	_status.tone = "muted"
	add_child(_status)

func get_list() -> ItemList:
	_ready()
	return _list

func set_title_text(text: String) -> void:
	_ready()
	_panel.set_title_text(text)

func set_help_text(text: String) -> void:
	_ready()
	_panel.set_help_text(text)

func set_status_text(text: String, tone: String = "muted") -> void:
	_ready()
	_status.tone = tone
	_status.set_text_value(text)

