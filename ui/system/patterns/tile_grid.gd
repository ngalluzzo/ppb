@tool
class_name TileGrid
extends ScrollContainer

var _grid: GridContainer

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	if _grid != null:
		return
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_grid)

func get_grid_root() -> GridContainer:
	_ensure_ui()
	return _grid

