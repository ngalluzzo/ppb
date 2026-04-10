@tool
class_name TerrainValidationIssue
extends RefCounted

enum Severity {
	INFO,
	WARNING,
	ERROR,
}

var severity: int = Severity.WARNING
var kind: StringName = &""
var message: String = ""
var target_type: StringName = &""
var source_id: int = -1
var atlas_coords: Vector2i = Vector2i.ZERO
var cell: Vector2i = Vector2i.ZERO
var node_path: NodePath = NodePath("")

func to_display_text() -> String:
	var prefix := "INFO"
	if severity == Severity.WARNING:
		prefix = "WARN"
	elif severity == Severity.ERROR:
		prefix = "ERROR"
	return "[%s] %s" % [prefix, message]

