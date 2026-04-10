@tool
class_name AppButton
extends Button

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

enum Variant {
	PRIMARY,
	SECONDARY,
	GHOST,
	DANGER,
}

@export var scope: int = AppUIScript.Scope.RUNTIME:
	set(value):
		scope = value
		_apply_style()

@export var variant: Variant = Variant.SECONDARY:
	set(value):
		variant = value
		_apply_style()

func _ready() -> void:
	_apply_style()

func _apply_style() -> void:
	if not is_inside_tree():
		return
	AppUIScript.apply_theme(self, scope)
	var variant_name := _variant_name()
	add_theme_stylebox_override("normal", AppUIScript.make_button_style(variant_name, &"normal", scope))
	add_theme_stylebox_override("hover", AppUIScript.make_button_style(variant_name, &"hover", scope))
	add_theme_stylebox_override("pressed", AppUIScript.make_button_style(variant_name, &"pressed", scope))
	add_theme_stylebox_override("disabled", AppUIScript.make_button_style(variant_name, &"disabled", scope))
	add_theme_stylebox_override("focus", AppUIScript.make_button_style(variant_name, &"focus", scope))
	add_theme_color_override("font_color", AppUIScript.color(&"primary", scope))

func _variant_name() -> StringName:
	match variant:
		Variant.PRIMARY:
			return &"primary"
		Variant.GHOST:
			return &"ghost"
		Variant.DANGER:
			return &"danger"
		_:
			return &"secondary"
