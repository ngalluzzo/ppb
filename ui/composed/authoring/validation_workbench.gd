@tool
class_name ValidationWorkbench
extends VBoxContainer

const ActionToolbarScript = preload("res://ui/system/blocks/action_toolbar.gd")
const ValidationListPanelScript = preload("res://ui/system/blocks/validation_list_panel.gd")
const IssueSummaryStripScript = preload("res://ui/system/blocks/issue_summary_strip.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

signal action_pressed(id: StringName)

var _summary: IssueSummaryStrip
var _toolbar: ActionToolbar
var _panel: ValidationListPanel

func _ready() -> void:
	if _panel != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_summary = IssueSummaryStripScript.new()
	_summary.scope = scope
	add_child(_summary)
	_toolbar = ActionToolbarScript.new()
	_toolbar.scope = scope
	_toolbar.action_pressed.connect(action_pressed.emit)
	add_child(_toolbar)
	_panel = ValidationListPanelScript.new()
	_panel.scope = scope
	add_child(_panel)

func set_issue_counts(errors: int, warnings: int, info: int) -> void:
	_ready()
	_summary.set_counts(errors, warnings, info)

func set_actions(actions: Array) -> void:
	_ready()
	_toolbar.set_actions(actions)

func get_list() -> ItemList:
	_ready()
	return _panel.get_list()

func set_title_text(text: String) -> void:
	_ready()
	_panel.set_title_text(text)

func set_summary_text(text: String) -> void:
	_ready()
	_panel.set_summary_text(text)
