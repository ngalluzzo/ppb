@tool
extends Control

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const ToolDockShellScript = preload("res://ui/system/blocks/tool_dock_shell.gd")
const InspectorSectionScript = preload("res://ui/system/blocks/inspector_section.gd")
const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const ValidationListPanelScript = preload("res://ui/system/blocks/validation_list_panel.gd")
const PreviewPanelScript = preload("res://ui/system/blocks/preview_panel.gd")
const StatusBannerScript = preload("res://ui/system/blocks/status_banner.gd")
const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const AppBadgeScript = preload("res://ui/system/primitives/app_badge.gd")
const AppSelectFieldScript = preload("res://ui/system/primitives/app_select_field.gd")

func _ready() -> void:
	var shell := ToolDockShellScript.new()
	shell.scope = AppUIScript.Scope.EDITOR
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.set_title_text("UI System Gallery")
	shell.set_help_text("A compact demo of tokens, primitives, and workflow blocks.")
	add_child(shell)

	var section := InspectorSectionScript.new()
	section.scope = AppUIScript.Scope.EDITOR
	section.set_title_text("Primitives")
	section.set_path_text("res://ui/system/")
	shell.get_content_root().add_child(section)

	var field := InspectorFieldRowScript.new()
	field.scope = AppUIScript.Scope.EDITOR
	field.set_label_text("Controls")
	section.get_content_root().add_child(field)

	var primary := AppButtonScript.new()
	primary.scope = AppUIScript.Scope.EDITOR
	primary.variant = AppButtonScript.Variant.PRIMARY
	primary.text = "Primary"
	field.get_content_root().add_child(primary)

	var ghost := AppButtonScript.new()
	ghost.scope = AppUIScript.Scope.EDITOR
	ghost.variant = AppButtonScript.Variant.GHOST
	ghost.text = "Ghost"
	field.get_content_root().add_child(ghost)

	var select := AppSelectFieldScript.new()
	select.scope = AppUIScript.Scope.EDITOR
	select.add_item("Option A")
	select.add_item("Option B")
	field.get_content_root().add_child(select)

	var badge_row := InspectorFieldRowScript.new()
	badge_row.scope = AppUIScript.Scope.EDITOR
	badge_row.set_label_text("Badges")
	section.get_content_root().add_child(badge_row)
	for variant in ["neutral", "success", "warning", "error", "info"]:
		var badge := AppBadgeScript.new()
		badge.scope = AppUIScript.Scope.EDITOR
		badge.variant = variant
		badge.text_value = variant.capitalize()
		badge_row.get_content_root().add_child(badge)

	var preview := PreviewPanelScript.new()
	preview.scope = AppUIScript.Scope.EDITOR
	preview.set_title_text("Preview Panel")
	preview.set_help_text("Embed exact-preview or visualization surfaces inside this block.")
	shell.get_content_root().add_child(preview)

	var banner := StatusBannerScript.new()
	banner.scope = AppUIScript.Scope.EDITOR
	banner.tone = "info"
	banner.set_text_value("StatusBanner: consistent inline feedback for tools and runtime controls.")
	preview.get_content_root().add_child(banner)

	var validation := ValidationListPanelScript.new()
	validation.scope = AppUIScript.Scope.EDITOR
	validation.set_title_text("Validation Panel")
	validation.set_summary_text("Errors: 1 | Warnings: 1 | Info: 1")
	var list := validation.get_list()
	list.add_item("[ERROR] Missing collision on tile (4, 2).")
	list.add_item("[WARN] Spawn lane camera exceeds camera bounds.")
	list.add_item("[INFO] Preview sandbox active.")
	shell.get_content_root().add_child(validation)
