@tool
class_name OverlayToggleCluster
extends VBoxContainer

const AppCheckFieldScript = preload("res://ui/system/primitives/app_check_field.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.EDITOR

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"xs", scope))

func add_toggle(label: String, callback: Callable) -> CheckBox:
	var toggle := AppCheckFieldScript.new()
	toggle.scope = scope
	toggle.text = label
	if not callback.is_null():
		toggle.toggled.connect(callback)
	add_child(toggle)
	return toggle

