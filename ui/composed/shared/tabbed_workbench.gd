@tool
class_name TabbedWorkbench
extends VBoxContainer

const AppTabsScript = preload("res://ui/system/primitives/app_tabs.gd")
const IssueSummaryStripScript = preload("res://ui/system/blocks/issue_summary_strip.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

var _summary_strip: IssueSummaryStrip
var _tabs: TabContainer

func _ready() -> void:
	if _tabs != null:
		return
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_summary_strip = IssueSummaryStripScript.new()
	_summary_strip.scope = scope
	add_child(_summary_strip)
	_tabs = AppTabsScript.new()
	_tabs.scope = scope
	_tabs.size_flags_horizontal = SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_tabs)

func set_issue_counts(errors: int, warnings: int, info: int) -> void:
	_ready()
	_summary_strip.set_counts(errors, warnings, info)

func get_tabs() -> TabContainer:
	_ready()
	return _tabs

