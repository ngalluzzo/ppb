@tool
class_name MetricTriplet
extends HBoxContainer

const AppPanelScript = preload("res://ui/system/primitives/app_panel.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

func set_metrics(metrics: Array) -> void:
	for child in get_children():
		child.queue_free()
	for metric in metrics:
		var panel := AppPanelScript.new()
		panel.scope = scope
		panel.variant = "inset"
		panel.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(panel)
		var box := VBoxContainer.new()
		box.size_flags_horizontal = SIZE_EXPAND_FILL
		panel.add_child(box)
		var label := AppLabelScript.new()
		label.scope = scope
		label.role = "caption"
		label.text_role = "muted"
		label.text = str(metric.label if metric != null else "")
		box.add_child(label)
		var value := AppLabelScript.new()
		value.scope = scope
		value.role = "section"
		value.text_role = String(metric.tone if metric != null else &"primary")
		value.text = str(metric.value if metric != null else "")
		box.add_child(value)
		if metric != null and str(metric.hint) != "":
			var hint := AppLabelScript.new()
			hint.scope = scope
			hint.role = "caption"
			hint.text_role = "muted"
			hint.text = str(metric.hint)
			box.add_child(hint)

