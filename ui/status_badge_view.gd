class_name StatusBadgeView
extends PanelContainer

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const StatusDefinitionScript = preload("res://mobile/status/status_definition.gd")

func configure(view_state, badge_size: Vector2 = Vector2(34, 34)) -> void:
	var icon_rect: TextureRect = get_node("Content/Icon")
	var short_label: Label = get_node("Content/ShortLabel")
	var turns_label: Label = get_node("Content/TurnsLabel")
	var stacks_label: Label = get_node("Content/StacksLabel")
	custom_minimum_size = badge_size
	size = badge_size
	tooltip_text = view_state.get_tooltip_text() if view_state != null else ""
	if view_state == null:
		visible = false
		return
	visible = true
	_theme_badge(view_state)
	var has_icon := view_state.icon != null
	icon_rect.texture = view_state.icon
	icon_rect.visible = has_icon
	short_label.visible = not has_icon
	short_label.text = view_state.short_label
	short_label.add_theme_font_size_override("font_size", int(round(badge_size.y * 0.36)))
	turns_label.text = str(maxi(0, view_state.remaining_turns))
	turns_label.add_theme_font_size_override("font_size", int(round(badge_size.y * 0.27)))
	stacks_label.visible = view_state.stacks > 1
	stacks_label.text = "x%d" % view_state.stacks
	stacks_label.add_theme_font_size_override("font_size", int(round(badge_size.y * 0.2)))

func _theme_badge(view_state) -> void:
	var short_label: Label = get_node("Content/ShortLabel")
	var turns_label: Label = get_node("Content/TurnsLabel")
	var stacks_label: Label = get_node("Content/StacksLabel")
	AppUIScript.apply_theme(self, AppUIScript.Scope.RUNTIME)
	var style := AppUIScript.make_badge_style(&"info", AppUIScript.Scope.RUNTIME, view_state.tint)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = _border_color(view_state)
	add_theme_stylebox_override("panel", style)
	short_label.add_theme_color_override("font_color", AppUIScript.color(&"primary", AppUIScript.Scope.RUNTIME))
	turns_label.add_theme_color_override("font_color", AppUIScript.color(&"primary", AppUIScript.Scope.RUNTIME))
	stacks_label.add_theme_color_override("font_color", AppUIScript.color(&"warning", AppUIScript.Scope.RUNTIME))

func _border_color(view_state) -> Color:
	match view_state.polarity:
		StatusDefinitionScript.Polarity.BUFF:
			return view_state.tint.lightened(0.25)
		StatusDefinitionScript.Polarity.DEBUFF:
			return view_state.tint.darkened(0.1).lerp(Color(0.15, 0.05, 0.05, 1.0), 0.25)
		_:
			return view_state.tint.lightened(0.12)
