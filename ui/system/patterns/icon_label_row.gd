@tool
class_name IconLabelRow
extends HBoxContainer

const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

var _icon: TextureRect
var _primary: AppLabel
var _secondary: AppLabel

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _icon != null:
		return
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2.ONE * AppUIScript.icon_size(&"md", scope)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_icon)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(labels)
	_primary = AppLabelScript.new()
	_primary.scope = scope
	_primary.role = "body"
	labels.add_child(_primary)
	_secondary = AppLabelScript.new()
	_secondary.scope = scope
	_secondary.role = "caption"
	_secondary.text_role = "muted"
	labels.add_child(_secondary)

func configure(text: String, subtext: String = "", icon: Texture2D = null) -> void:
	_ensure_ui()
	_primary.text = text
	_secondary.text = subtext
	_secondary.visible = subtext != ""
	_icon.texture = icon
	_icon.visible = icon != null

