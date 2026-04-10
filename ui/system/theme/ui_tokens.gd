@tool
class_name UIThemeTokens
extends Resource

@export var surface_canvas: Color = Color(0.08, 0.10, 0.12, 1.0)
@export var surface_panel: Color = Color(0.13, 0.16, 0.19, 0.98)
@export var surface_panel_alt: Color = Color(0.16, 0.20, 0.23, 0.98)
@export var surface_inset: Color = Color(0.10, 0.12, 0.15, 1.0)
@export var surface_overlay: Color = Color(0.05, 0.06, 0.08, 0.88)

@export var text_primary: Color = Color(0.92, 0.94, 0.96, 1.0)
@export var text_muted: Color = Color(0.67, 0.72, 0.78, 1.0)
@export var text_accent: Color = Color(0.98, 0.87, 0.53, 1.0)
@export var text_danger: Color = Color(0.96, 0.49, 0.49, 1.0)
@export var text_success: Color = Color(0.54, 0.89, 0.67, 1.0)
@export var text_warning: Color = Color(0.99, 0.82, 0.42, 1.0)

@export var accent_interactive: Color = Color(0.39, 0.66, 0.93, 1.0)
@export var accent_highlight: Color = Color(0.99, 0.79, 0.38, 1.0)
@export var accent_selection: Color = Color(0.51, 0.80, 0.97, 1.0)
@export var accent_disabled: Color = Color(0.36, 0.41, 0.47, 1.0)

@export var border_soft: Color = Color(0.25, 0.31, 0.37, 1.0)
@export var border_strong: Color = Color(0.41, 0.49, 0.57, 1.0)
@export var border_focus: Color = Color(0.97, 0.78, 0.36, 1.0)

@export_range(0, 64, 1) var spacing_xs: int = 4
@export_range(0, 64, 1) var spacing_sm: int = 8
@export_range(0, 64, 1) var spacing_md: int = 12
@export_range(0, 64, 1) var spacing_lg: int = 18
@export_range(0, 64, 1) var spacing_xl: int = 28

@export_range(0, 64, 1) var radius_sm: int = 6
@export_range(0, 64, 1) var radius_md: int = 10
@export_range(0, 64, 1) var radius_lg: int = 14

@export_range(8, 128, 1) var icon_sm: int = 14
@export_range(8, 128, 1) var icon_md: int = 20
@export_range(8, 128, 1) var icon_lg: int = 28

@export_range(16, 96, 1) var control_height_compact: int = 24
@export_range(16, 96, 1) var control_height_default: int = 32
@export_range(16, 128, 1) var control_height_hero: int = 44

@export_range(0, 64, 1) var panel_density_dense: int = 8
@export_range(0, 64, 1) var panel_density_default: int = 12
@export_range(0, 64, 1) var panel_density_relaxed: int = 18

@export_range(1, 8, 1) var stroke_thin: int = 1
@export_range(1, 8, 1) var stroke_medium: int = 2
@export_range(1, 8, 1) var stroke_thick: int = 3

@export_range(0.0, 1.0, 0.01) var opacity_muted: float = 0.72
@export_range(0.0, 1.0, 0.01) var opacity_disabled: float = 0.45
@export_range(0.0, 1.0, 0.01) var opacity_overlay: float = 0.88

@export_range(0, 128, 1) var layer_base: int = 0
@export_range(0, 128, 1) var layer_overlay: int = 10
@export_range(0, 128, 1) var layer_modal: int = 20

@export_range(8, 96, 1) var font_caption: int = 11
@export_range(8, 96, 1) var font_body: int = 14
@export_range(8, 96, 1) var font_label: int = 13
@export_range(8, 96, 1) var font_section: int = 15
@export_range(8, 96, 1) var font_title: int = 22
@export_range(8, 128, 1) var font_display: int = 36

@export_range(0.01, 4.0, 0.01) var motion_fast: float = 0.10
@export_range(0.01, 4.0, 0.01) var motion_normal: float = 0.22
@export_range(0.01, 4.0, 0.01) var motion_slow: float = 0.40

func get_color(role: StringName) -> Color:
	match role:
		&"canvas":
			return surface_canvas
		&"panel":
			return surface_panel
		&"panel_alt":
			return surface_panel_alt
		&"inset":
			return surface_inset
		&"overlay":
			return surface_overlay
		&"primary":
			return text_primary
		&"muted":
			return text_muted
		&"accent":
			return text_accent
		&"danger":
			return text_danger
		&"success":
			return text_success
		&"warning":
			return text_warning
		&"interactive":
			return accent_interactive
		&"highlight":
			return accent_highlight
		&"selection":
			return accent_selection
		&"disabled":
			return accent_disabled
		&"soft":
			return border_soft
		&"strong":
			return border_strong
		&"focus":
			return border_focus
		_:
			return text_primary

func get_spacing(role: StringName) -> int:
	match role:
		&"xs":
			return spacing_xs
		&"sm":
			return spacing_sm
		&"md":
			return spacing_md
		&"lg":
			return spacing_lg
		&"xl":
			return spacing_xl
		_:
			return spacing_md

func get_radius(role: StringName) -> int:
	match role:
		&"sm":
			return radius_sm
		&"lg":
			return radius_lg
		_:
			return radius_md

func get_icon_size(role: StringName) -> int:
	match role:
		&"sm":
			return icon_sm
		&"lg":
			return icon_lg
		_:
			return icon_md

func get_control_height(role: StringName) -> int:
	match role:
		&"compact":
			return control_height_compact
		&"hero":
			return control_height_hero
		_:
			return control_height_default

func get_panel_density(role: StringName) -> int:
	match role:
		&"dense":
			return panel_density_dense
		&"relaxed":
			return panel_density_relaxed
		_:
			return panel_density_default

func get_stroke(role: StringName) -> int:
	match role:
		&"medium":
			return stroke_medium
		&"thick":
			return stroke_thick
		_:
			return stroke_thin

func get_opacity(role: StringName) -> float:
	match role:
		&"disabled":
			return opacity_disabled
		&"overlay":
			return opacity_overlay
		_:
			return opacity_muted

func get_layer(role: StringName) -> int:
	match role:
		&"overlay":
			return layer_overlay
		&"modal":
			return layer_modal
		_:
			return layer_base

func get_font_size(role: StringName) -> int:
	match role:
		&"caption":
			return font_caption
		&"body":
			return font_body
		&"label":
			return font_label
		&"section":
			return font_section
		&"title":
			return font_title
		&"display":
			return font_display
		_:
			return font_body

func get_motion(role: StringName) -> float:
	match role:
		&"fast":
			return motion_fast
		&"slow":
			return motion_slow
		_:
			return motion_normal
