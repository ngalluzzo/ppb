@tool
class_name TerrainBrushState
extends RefCounted

const MODE_PAINT := &"paint"
const MODE_FILL_RECT := &"fill_rect"
const MODE_ERASE := &"erase"
const MODE_REPLACE_RECT := &"replace_rect"
const MODE_SAMPLE := &"sample"

var mode: StringName = MODE_PAINT
var brush_size: int = 1
var dragging: bool = false
var drag_start_cell: Vector2i = Vector2i.ZERO
var drag_current_cell: Vector2i = Vector2i.ZERO
var replace_source_tile_definition: TileDefinition

func is_rect_mode() -> bool:
	return mode == MODE_FILL_RECT or mode == MODE_REPLACE_RECT

func is_paint_stroke_mode() -> bool:
	return mode == MODE_PAINT or mode == MODE_ERASE

