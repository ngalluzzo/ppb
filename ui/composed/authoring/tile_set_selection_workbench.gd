@tool
class_name TileSetSelectionWorkbench
extends VBoxContainer

const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const ActionToolbarScript = preload("res://ui/system/blocks/action_toolbar.gd")
const PreviewPanelScript = preload("res://ui/system/blocks/preview_panel.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

signal action_pressed(id: StringName)

var _selection_status: StatusCallout
var _toolbar: ActionToolbar
var _panel: PreviewPanel
var _list: ItemList

func _ready() -> void:
	if _panel != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_selection_status = StatusCalloutScript.new()
	_selection_status.scope = scope
	add_child(_selection_status)
	_toolbar = ActionToolbarScript.new()
	_toolbar.scope = scope
	_toolbar.action_pressed.connect(action_pressed.emit)
	add_child(_toolbar)
	_panel = PreviewPanelScript.new()
	_panel.scope = scope
	_panel.set_title_text("Atlas Cells")
	add_child(_panel)
	_list = ItemList.new()
	_list.select_mode = ItemList.SELECT_MULTI
	_list.fixed_icon_size = Vector2i(48, 48)
	_list.max_columns = 6
	_list.same_column_width = true
	_list.allow_reselect = true
	_list.size_flags_vertical = SIZE_EXPAND_FILL
	_list.size_flags_horizontal = SIZE_EXPAND_FILL
	_panel.get_content_root().add_child(_list)

func get_list() -> ItemList:
	_ready()
	return _list

func set_actions(actions: Array) -> void:
	_ready()
	_toolbar.set_actions(actions)

func set_selection_status(text: String, tone: String = "muted") -> void:
	_ready()
	_selection_status.tone = tone
	_selection_status.set_text_value(text)

func set_title_text(text: String) -> void:
	_ready()
	_panel.set_title_text(text)

func set_help_text(text: String) -> void:
	_ready()
	_panel.set_help_text(text)
