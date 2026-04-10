@tool
class_name ExactPreviewPanel
extends VBoxContainer

const PreviewPanelScript = preload("res://ui/system/blocks/preview_panel.gd")
const PreviewLegendScript = preload("res://ui/system/blocks/preview_legend.gd")
const PreviewTransportScript = preload("res://ui/system/blocks/preview_transport.gd")
const TrajectorySummaryStripScript = preload("res://ui/composed/authoring/trajectory_summary_strip.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

signal replay_pressed
signal start_pressed
signal pause_pressed

@export var scope: int = AppUIScript.Scope.EDITOR

var _panel: PreviewPanel
var _transport: PreviewTransport
var _summary: TrajectorySummaryStrip
var _legend: PreviewLegend

func _ready() -> void:
	if _panel != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_panel = PreviewPanelScript.new()
	_panel.scope = scope
	_panel.set_title_text("Exact Preview")
	add_child(_panel)
	_transport = PreviewTransportScript.new()
	_transport.scope = scope
	_transport.replay_pressed.connect(replay_pressed.emit)
	_transport.reset_pressed.connect(start_pressed.emit)
	_transport.pause_pressed.connect(pause_pressed.emit)
	add_child(_transport)
	_summary = TrajectorySummaryStripScript.new()
	_summary.scope = scope
	add_child(_summary)
	_legend = PreviewLegendScript.new()
	_legend.scope = scope
	add_child(_legend)

func get_preview_root() -> VBoxContainer:
	_ready()
	return _panel.get_content_root()

func set_title_text(text: String) -> void:
	_ready()
	_panel.set_title_text(text)

func set_help_text(text: String) -> void:
	_ready()
	_panel.set_help_text(text)

func set_summary(summary: Dictionary) -> void:
	_ready()
	_summary.set_summary(summary)

func set_legend(entries: Array) -> void:
	_ready()
	_legend.set_entries(entries)
