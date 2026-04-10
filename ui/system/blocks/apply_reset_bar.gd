@tool
class_name ApplyResetBar
extends HBoxContainer

const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")

signal reset_pressed()
signal apply_pressed()
signal replay_pressed()

@export var scope: int = 1

var _reset_button: Button
var _apply_button: Button
var _replay_button: Button

func _ready() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _reset_button == null:
		_reset_button = AppButtonScript.new()
		_reset_button.scope = scope
		_reset_button.variant = AppButtonScript.Variant.GHOST
		_reset_button.text = "Reset"
		_reset_button.pressed.connect(func(): reset_pressed.emit())
		add_child(_reset_button)
	if _apply_button == null:
		_apply_button = AppButtonScript.new()
		_apply_button.scope = scope
		_apply_button.variant = AppButtonScript.Variant.PRIMARY
		_apply_button.text = "Apply"
		_apply_button.pressed.connect(func(): apply_pressed.emit())
		add_child(_apply_button)
	if _replay_button == null:
		_replay_button = AppButtonScript.new()
		_replay_button.scope = scope
		_replay_button.variant = AppButtonScript.Variant.SECONDARY
		_replay_button.text = "Replay"
		_replay_button.pressed.connect(func(): replay_pressed.emit())
		add_child(_replay_button)

func set_labels(reset_text: String, apply_text: String, replay_text: String) -> void:
	if _reset_button != null:
		_reset_button.text = reset_text
	if _apply_button != null:
		_apply_button.text = apply_text
	if _replay_button != null:
		_replay_button.text = replay_text
