@tool
class_name HeroTitleStack
extends VBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _subtitle: AppLabel
var _prompt: AppLabel

func _ready() -> void:
	if _subtitle != null:
		return
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", AppUIScript.spacing(&"md", scope))
	_subtitle = AppLabelScript.new()
	_subtitle.name = "Subtitle"
	_subtitle.scope = scope
	_subtitle.role = "section"
	_subtitle.text_role = "muted"
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_subtitle)
	_prompt = AppLabelScript.new()
	_prompt.name = "Prompt"
	_prompt.scope = scope
	_prompt.role = "title"
	_prompt.text_role = "accent"
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_prompt)

func get_subtitle_label() -> AppLabel:
	_ready()
	return _subtitle

func get_prompt_label() -> AppLabel:
	_ready()
	return _prompt

func set_subtitle_text(text: String) -> void:
	_ready()
	_subtitle.text = text

func set_prompt_text(text: String) -> void:
	_ready()
	_prompt.text = text
