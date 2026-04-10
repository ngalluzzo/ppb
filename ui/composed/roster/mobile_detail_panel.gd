@tool
class_name MobileDetailPanel
extends VBoxContainer

const MobileCardScript = preload("res://ui/composed/roster/mobile_card.gd")
const StatColumnSummaryScript = preload("res://ui/composed/roster/stat_column_summary.gd")
const LoadoutStripScript = preload("res://ui/composed/roster/loadout_strip.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _card: MobileCard
var _stats: StatColumnSummary
var _loadout: LoadoutStrip

func _ready() -> void:
	if _card != null:
		return
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	_card = MobileCardScript.new()
	_card.scope = scope
	add_child(_card)
	_stats = StatColumnSummaryScript.new()
	_stats.scope = scope
	add_child(_stats)
	_loadout = LoadoutStripScript.new()
	_loadout.scope = scope
	add_child(_loadout)

func configure(name_text: String, subtitle_text: String, tags: Array[String], stats: Array[Dictionary], loadout: Array) -> void:
	_ready()
	_card.configure(name_text, subtitle_text, tags)
	_stats.set_rows(stats)
	_loadout.set_shots(loadout)

