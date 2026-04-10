@tool
class_name AppBadge
extends PanelContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

@export_enum("neutral", "success", "warning", "error", "info") var variant: String = "neutral":
	set(value):
		variant = value
		_apply_style()

@export var text_value: String = "":
	set(value):
		text_value = value
		if _label != null:
			_label.text = value

var _label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _label == null:
		_label = Label.new()
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(_label)
	_label.text = text_value
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	add_theme_stylebox_override("panel", AppUIScript.make_badge_style(StringName(variant), scope))
	if _label != null:
		AppUIScript.configure_text_control(_label, &"caption", &"primary", scope)
