@tool
class_name AppUI
extends RefCounted

const RuntimeTokens = preload("res://ui/system/theme/app_ui_tokens.tres")
const EditorTokens = preload("res://ui/system/theme/editor_ui_tokens.tres")
const RuntimeThemeBase = preload("res://ui/system/theme/app_theme.tres")
const EditorThemeBase = preload("res://ui/system/theme/editor_theme.tres")

enum Scope {
	RUNTIME,
	EDITOR,
}

static var _theme_cache: Dictionary = {}

static func get_tokens(scope: int = Scope.RUNTIME) -> UIThemeTokens:
	return EditorTokens if scope == Scope.EDITOR else RuntimeTokens

static func get_theme(scope: int = Scope.RUNTIME) -> Theme:
	if _theme_cache.has(scope):
		return _theme_cache[scope]
	var base: Theme = (EditorThemeBase if scope == Scope.EDITOR else RuntimeThemeBase).duplicate(true)
	var tokens := get_tokens(scope)
	base.default_font_size = tokens.get_font_size(&"body")
	_configure_theme(base, tokens)
	_theme_cache[scope] = base
	return base

static func apply_theme(control: Control, scope: int = Scope.RUNTIME) -> void:
	if control == null:
		return
	control.theme = get_theme(scope)

static func color(role: StringName, scope: int = Scope.RUNTIME) -> Color:
	return get_tokens(scope).get_color(role)

static func spacing(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_spacing(role)

static func radius(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_radius(role)

static func font_size(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_font_size(role)

static func motion(role: StringName, scope: int = Scope.RUNTIME) -> float:
	return get_tokens(scope).get_motion(role)

static func icon_size(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_icon_size(role)

static func control_height(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_control_height(role)

static func panel_density(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_panel_density(role)

static func stroke(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_stroke(role)

static func opacity(role: StringName, scope: int = Scope.RUNTIME) -> float:
	return get_tokens(scope).get_opacity(role)

static func layer(role: StringName, scope: int = Scope.RUNTIME) -> int:
	return get_tokens(scope).get_layer(role)

static func make_panel_style(variant: StringName, scope: int = Scope.RUNTIME) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _surface_color_for_variant(variant, scope)
	style.border_color = color(&"soft", scope)
	style.border_width_left = stroke(&"thin", scope)
	style.border_width_top = stroke(&"thin", scope)
	style.border_width_right = stroke(&"thin", scope)
	style.border_width_bottom = stroke(&"thin", scope)
	style.corner_radius_top_left = radius(&"md", scope)
	style.corner_radius_top_right = radius(&"md", scope)
	style.corner_radius_bottom_right = radius(&"md", scope)
	style.corner_radius_bottom_left = radius(&"md", scope)
	style.content_margin_left = panel_density(&"default", scope)
	style.content_margin_top = panel_density(&"default", scope)
	style.content_margin_right = panel_density(&"default", scope)
	style.content_margin_bottom = panel_density(&"default", scope)
	if variant == &"inset":
		style.border_color = color(&"strong", scope).darkened(0.18)
	elif variant == &"accent":
		style.border_color = color(&"highlight", scope)
	return style

static func make_field_style(focused: bool, scope: int = Scope.RUNTIME) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color(&"inset", scope)
	style.border_color = color(&"focus", scope) if focused else color(&"soft", scope)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius(&"sm", scope)
	style.corner_radius_top_right = radius(&"sm", scope)
	style.corner_radius_bottom_right = radius(&"sm", scope)
	style.corner_radius_bottom_left = radius(&"sm", scope)
	style.content_margin_left = spacing(&"sm", scope)
	style.content_margin_top = spacing(&"xs", scope)
	style.content_margin_right = spacing(&"sm", scope)
	style.content_margin_bottom = spacing(&"xs", scope)
	return style

static func make_button_style(variant: StringName, state: StringName, scope: int = Scope.RUNTIME) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var base_bg := _button_bg_for_variant(variant, scope)
	var border := _button_border_for_variant(variant, scope)
	match state:
		&"hover":
			base_bg = base_bg.lightened(0.08)
		&"pressed":
			base_bg = base_bg.darkened(0.14)
		&"disabled":
			base_bg = color(&"disabled", scope).darkened(0.08)
			border = color(&"disabled", scope)
		&"focus":
			border = color(&"focus", scope)
	style.bg_color = base_bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius(&"sm", scope)
	style.corner_radius_top_right = radius(&"sm", scope)
	style.corner_radius_bottom_right = radius(&"sm", scope)
	style.corner_radius_bottom_left = radius(&"sm", scope)
	style.content_margin_left = spacing(&"sm", scope)
	style.content_margin_top = spacing(&"xs", scope)
	style.content_margin_right = spacing(&"sm", scope)
	style.content_margin_bottom = spacing(&"xs", scope)
	return style

static func make_badge_style(variant: StringName, scope: int = Scope.RUNTIME, tint: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := _badge_bg_for_variant(variant, scope)
	var border := _badge_border_for_variant(variant, scope)
	if tint != Color.TRANSPARENT:
		bg = tint.lerp(Color.BLACK, 0.18)
		border = tint.lightened(0.15)
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius(&"sm", scope)
	style.corner_radius_top_right = radius(&"sm", scope)
	style.corner_radius_bottom_right = radius(&"sm", scope)
	style.corner_radius_bottom_left = radius(&"sm", scope)
	style.content_margin_left = spacing(&"sm", scope)
	style.content_margin_top = spacing(&"xs", scope)
	style.content_margin_right = spacing(&"sm", scope)
	style.content_margin_bottom = spacing(&"xs", scope)
	return style

static func make_label_settings(role: StringName, scope: int = Scope.RUNTIME, text_role: StringName = &"primary") -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = font_size(role, scope)
	settings.font_color = color(text_role, scope)
	if role == &"title" or role == &"display":
		settings.outline_size = 4 if scope == Scope.RUNTIME else 2
		settings.outline_color = color(&"overlay", scope)
	return settings

static func configure_text_control(control: Control, role: StringName = &"body", text_role: StringName = &"primary", scope: int = Scope.RUNTIME) -> void:
	if control == null:
		return
	control.add_theme_font_size_override("font_size", font_size(role, scope))
	control.add_theme_color_override("font_color", color(text_role, scope))

static func style_runtime_label(label: Label, role: StringName = &"body", text_role: StringName = &"primary") -> void:
	configure_text_control(label, role, text_role, Scope.RUNTIME)

static func style_editor_label(label: Label, role: StringName = &"body", text_role: StringName = &"primary") -> void:
	configure_text_control(label, role, text_role, Scope.EDITOR)

static func configure_status_badge(panel: PanelContainer, tint: Color, scope: int = Scope.RUNTIME) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", make_badge_style(&"info", scope, tint))

static func _configure_theme(theme: Theme, tokens: UIThemeTokens) -> void:
	theme.set_color("font_color", "Label", tokens.text_primary)
	theme.set_color("font_placeholder_color", "LineEdit", tokens.text_muted)
	theme.set_color("font_color", "LineEdit", tokens.text_primary)
	theme.set_color("font_color", "Button", tokens.text_primary)
	theme.set_color("font_color", "CheckBox", tokens.text_primary)
	theme.set_color("font_color", "OptionButton", tokens.text_primary)
	theme.set_constant("separation", "VBoxContainer", tokens.spacing_sm)
	theme.set_constant("separation", "HBoxContainer", tokens.spacing_sm)
	theme.set_constant("h_separation", "GridContainer", tokens.spacing_sm)
	theme.set_constant("v_separation", "GridContainer", tokens.spacing_sm)
	theme.set_stylebox("panel", "PanelContainer", make_panel_style(&"default", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	var field_normal := make_field_style(false, Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR)
	var field_focus := make_field_style(true, Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR)
	theme.set_stylebox("normal", "LineEdit", field_normal)
	theme.set_stylebox("focus", "LineEdit", field_focus)
	theme.set_stylebox("read_only", "LineEdit", field_normal)
	theme.set_stylebox("normal", "Button", make_button_style(&"secondary", &"normal", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("hover", "Button", make_button_style(&"secondary", &"hover", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("pressed", "Button", make_button_style(&"secondary", &"pressed", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("disabled", "Button", make_button_style(&"secondary", &"disabled", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("focus", "Button", make_button_style(&"secondary", &"focus", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("normal", "OptionButton", field_normal)
	theme.set_stylebox("hover", "OptionButton", field_focus)
	theme.set_stylebox("pressed", "OptionButton", field_normal)
	theme.set_stylebox("focus", "OptionButton", field_focus)
	theme.set_stylebox("normal", "SpinBox", field_normal)
	theme.set_stylebox("focus", "SpinBox", field_focus)
	theme.set_stylebox("tab_unselected", "TabBar", make_button_style(&"ghost", &"normal", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("tab_selected", "TabBar", make_button_style(&"secondary", &"normal", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))
	theme.set_stylebox("panel", "TabContainer", make_panel_style(&"default", Scope.RUNTIME if tokens == RuntimeTokens else Scope.EDITOR))

static func _surface_color_for_variant(variant: StringName, scope: int) -> Color:
	match variant:
		&"inset":
			return color(&"inset", scope)
		&"accent":
			return color(&"panel_alt", scope).lightened(0.05)
		_:
			return color(&"panel", scope)

static func _button_bg_for_variant(variant: StringName, scope: int) -> Color:
	match variant:
		&"primary":
			return color(&"interactive", scope)
		&"ghost":
			return color(&"panel_alt", scope).darkened(0.08)
		&"danger":
			return color(&"danger", scope).darkened(0.22)
		_:
			return color(&"panel_alt", scope)

static func _button_border_for_variant(variant: StringName, scope: int) -> Color:
	match variant:
		&"primary":
			return color(&"highlight", scope)
		&"ghost":
			return color(&"soft", scope)
		&"danger":
			return color(&"danger", scope).lightened(0.15)
		_:
			return color(&"strong", scope)

static func _badge_bg_for_variant(variant: StringName, scope: int) -> Color:
	match variant:
		&"success":
			return color(&"success", scope).darkened(0.58)
		&"warning":
			return color(&"warning", scope).darkened(0.58)
		&"error":
			return color(&"danger", scope).darkened(0.58)
		&"info":
			return color(&"interactive", scope).darkened(0.56)
		_:
			return color(&"panel_alt", scope)

static func _badge_border_for_variant(variant: StringName, scope: int) -> Color:
	match variant:
		&"success":
			return color(&"success", scope)
		&"warning":
			return color(&"warning", scope)
		&"error":
			return color(&"danger", scope)
		&"info":
			return color(&"interactive", scope)
		_:
			return color(&"strong", scope)
