@tool
class_name AppScrollPanel
extends "res://ui/system/primitives/app_panel.gd"

var _scroll: ScrollContainer
var _content_root: VBoxContainer

func _ready() -> void:
	super._ready()
	if _scroll == null:
		_scroll = ScrollContainer.new()
		_scroll.size_flags_vertical = SIZE_EXPAND_FILL
		_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(_scroll)
		_content_root = VBoxContainer.new()
		_content_root.size_flags_horizontal = SIZE_EXPAND_FILL
		_scroll.add_child(_content_root)

func get_content_root() -> VBoxContainer:
	_ready()
	return _content_root
