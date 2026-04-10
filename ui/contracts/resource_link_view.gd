class_name ResourceLinkView
extends RefCounted

var label: String = ""
var path: String = ""
var dirty: bool = false

func _init(p_label: String = "", p_path: String = "", p_dirty: bool = false) -> void:
	label = p_label
	path = p_path
	dirty = p_dirty
