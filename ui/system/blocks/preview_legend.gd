@tool
class_name PreviewLegend
extends VBoxContainer

const IconLabelRowScript = preload("res://ui/system/patterns/icon_label_row.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))

func set_entries(entries: Array) -> void:
	for child in get_children():
		child.queue_free()
	for entry in entries:
		var row := IconLabelRowScript.new()
		row.scope = scope
		row.configure(str(entry.get("label", "")), str(entry.get("hint", "")), entry.get("icon"))
		add_child(row)
