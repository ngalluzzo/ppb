@tool
class_name LabelValueTable
extends VBoxContainer

const LabelValueRowScript = preload("res://ui/system/patterns/label_value_row.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))

func set_rows(rows: Array[Dictionary]) -> void:
	for child in get_children():
		child.queue_free()
	for row_data in rows:
		var row := LabelValueRowScript.new()
		row.scope = scope
		row.set_label_text(str(row_data.get("label", "")))
		row.set_value_text(str(row_data.get("value", "")))
		row.set_value_role(StringName(str(row_data.get("tone", "primary"))))
		add_child(row)

