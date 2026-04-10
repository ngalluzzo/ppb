@tool
class_name LoadoutStrip
extends HBoxContainer

const ShotIdentityCardScript = preload("res://ui/composed/roster/shot_identity_card.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

@export var scope: int = AppUIScript.Scope.RUNTIME

func _ready() -> void:
	add_theme_constant_override("separation", AppUIScript.spacing(&"sm", scope))

func set_shots(views: Array) -> void:
	for child in get_children():
		child.queue_free()
	for view in views:
		var card := ShotIdentityCardScript.new()
		card.scope = scope
		card.size_flags_horizontal = SIZE_EXPAND_FILL
		card.set_view(view)
		add_child(card)

