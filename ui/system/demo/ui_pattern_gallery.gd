@tool
extends Control

const SectionStackScript = preload("res://ui/system/patterns/section_stack.gd")
const HeaderBodyFooterScript = preload("res://ui/system/patterns/header_body_footer.gd")
const SplitInspectorPreviewScript = preload("res://ui/system/patterns/split_inspector_preview.gd")
const MetricTripletScript = preload("res://ui/system/patterns/metric_triplet.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const MetricViewScript = preload("res://ui/contracts/metric_view.gd")

func _ready() -> void:
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)
	var root := SectionStackScript.new()
	root.scope = AppUIScript.Scope.EDITOR
	root.anchors_preset = PRESET_FULL_RECT
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	add_child(root)

	var header_body_footer := HeaderBodyFooterScript.new()
	header_body_footer.scope = AppUIScript.Scope.EDITOR
	root.add_child(header_body_footer)
	header_body_footer.get_header_root().add_child(_label("Header / Body / Footer"))
	header_body_footer.get_body_root().add_child(_label("Body region"))
	header_body_footer.get_footer_root().add_child(_label("Footer region"))

	var split := SplitInspectorPreviewScript.new()
	split.scope = AppUIScript.Scope.EDITOR
	split.custom_minimum_size = Vector2(0, 220)
	root.add_child(split)
	split.get_inspector_root().add_child(_label("Inspector region"))
	split.get_preview_root().add_child(_label("Preview region"))

	var metrics := MetricTripletScript.new()
	metrics.scope = AppUIScript.Scope.EDITOR
	metrics.set_metrics([
		MetricViewScript.new("Projectiles", "3"),
		MetricViewScript.new("Airtime", "1.4s"),
		MetricViewScript.new("Spread", "18px"),
	])
	root.add_child(metrics)

func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label

