@tool
class_name StatusBanner
extends "res://ui/system/primitives/app_panel.gd"

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

@export_enum("info", "success", "warning", "error", "muted") var tone: String = "info":
	set(value):
		tone = value
		_apply_tone()

var _label: Label

func _ready() -> void:
	if variant == "":
		variant = "inset"
	super._ready()
	if _label == null:
		_label = AppLabelScript.new()
		_label.scope = scope
		_label.role = "body"
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(_label)
	_apply_tone()

func set_text_value(text: String) -> void:
	if _label != null:
		_label.text = text

func _apply_tone() -> void:
	if not is_inside_tree():
		return
	var text_role := &"primary"
	match tone:
		"success":
			add_theme_stylebox_override("panel", AppUIScript.make_badge_style(&"success", scope))
			text_role = &"success"
		"warning":
			add_theme_stylebox_override("panel", AppUIScript.make_badge_style(&"warning", scope))
			text_role = &"warning"
		"error":
			add_theme_stylebox_override("panel", AppUIScript.make_badge_style(&"error", scope))
			text_role = &"danger"
		"muted":
			add_theme_stylebox_override("panel", AppUIScript.make_panel_style(&"inset", scope))
			text_role = &"muted"
		_:
			add_theme_stylebox_override("panel", AppUIScript.make_badge_style(&"info", scope))
			text_role = &"accent"
	if _label != null:
		_label.text_role = String(text_role)
