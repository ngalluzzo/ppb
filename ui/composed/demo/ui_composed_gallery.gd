@tool
extends Control

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const ExactPreviewPanelScript = preload("res://ui/composed/authoring/exact_preview_panel.gd")
const ValidationWorkbenchScript = preload("res://ui/composed/authoring/validation_workbench.gd")
const MobileCardScript = preload("res://ui/composed/roster/mobile_card.gd")
const TurnHeaderScript = preload("res://ui/composed/battle/turn_header.gd")
const HeroTitleStackScript = preload("res://ui/composed/title/hero_title_stack.gd")

func _ready() -> void:
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)
	var root := VBoxContainer.new()
	root.anchors_preset = PRESET_FULL_RECT
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	add_child(root)

	var hero := HeroTitleStackScript.new()
	hero.scope = AppUIScript.Scope.RUNTIME
	hero.set_subtitle_text("WORMS / GUNBOUND REINVENTED")
	hero.set_prompt_text("START")
	root.add_child(hero)

	var turn_header := TurnHeaderScript.new()
	turn_header.scope = AppUIScript.Scope.RUNTIME
	turn_header.set_turn_info("Ironclad", "Aiming", "22s")
	root.add_child(turn_header)

	var preview := ExactPreviewPanelScript.new()
	preview.scope = AppUIScript.Scope.EDITOR
	preview.set_title_text("Exact Preview")
	preview.set_summary({"projectile_count": 3, "airtime": "1.6s", "spread": "22px"})
	root.add_child(preview)

	var validation := ValidationWorkbenchScript.new()
	validation.scope = AppUIScript.Scope.EDITOR
	validation.set_title_text("Validation")
	validation.set_issue_counts(1, 2, 0)
	root.add_child(validation)

	var card := MobileCardScript.new()
	card.scope = AppUIScript.Scope.RUNTIME
	card.configure("Ironclad", "Heavy artillery brawler", ["Artillery", "Drill"])
	root.add_child(card)

