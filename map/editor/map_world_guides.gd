@tool
class_name MapWorldGuides
extends Node2D

const DEFAULT_BOUNDS := Rect2(0, 0, 2560, 1440)

@export var world_bounds: Rect2 = DEFAULT_BOUNDS:
	set(value):
		world_bounds = value
		queue_redraw()

@export var grid_step: int = 160:
	set(value):
		grid_step = max(16, value)
		queue_redraw()

var _fill_color := Color("4bb3fd", 0.08)
var _grid_color := Color("4bb3fd", 0.18)
var _border_color := Color("4bb3fd", 0.95)
var _accent_color := Color("f9d65c", 0.95)

func _ready() -> void:
	z_index = 100
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_rect(world_bounds, _fill_color, true)
	draw_rect(world_bounds, _border_color, false, 4.0)
	_draw_grid()
	_draw_axes()
	_draw_labels()

func _draw_grid() -> void:
	var start_x := int(world_bounds.position.x + grid_step)
	var end_x := int(world_bounds.end.x)
	for x in range(start_x, end_x, grid_step):
		draw_line(
			Vector2(x, world_bounds.position.y),
			Vector2(x, world_bounds.end.y),
			_grid_color,
			1.0
		)

	var start_y := int(world_bounds.position.y + grid_step)
	var end_y := int(world_bounds.end.y)
	for y in range(start_y, end_y, grid_step):
		draw_line(
			Vector2(world_bounds.position.x, y),
			Vector2(world_bounds.end.x, y),
			_grid_color,
			1.0
		)

func _draw_axes() -> void:
	var center := world_bounds.get_center()
	draw_line(
		Vector2(center.x, world_bounds.position.y),
		Vector2(center.x, world_bounds.end.y),
		_accent_color,
		2.0
	)
	draw_line(
		Vector2(world_bounds.position.x, center.y),
		Vector2(world_bounds.end.x, center.y),
		_accent_color,
		2.0
	)

func _draw_labels() -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return

	var font_size := 16
	var top_left := world_bounds.position + Vector2(12, 24)
	var bottom_right := world_bounds.end + Vector2(-180, -12)
	var center := world_bounds.get_center() + Vector2(12, -12)

	draw_string(font, top_left, "MAP WORLD", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, _border_color)
	draw_string(font, top_left + Vector2(0, 20), "origin (0, 0)", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, _border_color)
	draw_string(
		font,
		center,
		"center (%.0f, %.0f)" % [world_bounds.get_center().x, world_bounds.get_center().y],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		_accent_color
	)
	draw_string(
		font,
		bottom_right,
		"end (%.0f, %.0f)" % [world_bounds.end.x, world_bounds.end.y],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		_border_color
	)
