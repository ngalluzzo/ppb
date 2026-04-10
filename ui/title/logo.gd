extends Control

@onready var shadow: TextureRect = $Shadow
@onready var bots: TextureRect = $Bots
@onready var pewpew: TextureRect = $PewPew
@onready var cable_pivot: Control = $CablePivot
@onready var head: TextureRect = $CablePivot/Head
@onready var eye_glow: TextureRect = $CablePivot/Head/EyeGlow
@onready var sheen: TextureRect = $SheenOverlay
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const INTRO_NAME: StringName = &"intro"
const IDLE_NAME: StringName = &"idle"
const SHEEN_NAME: StringName = &"sheen_pass"

var _base_shadow_position: Vector2
var _base_shadow_scale: Vector2
var _base_shadow_modulate: Color
var _base_bots_position: Vector2
var _base_pewpew_position: Vector2
var _base_pewpew_rotation: float
var _base_cable_rotation: float
var _base_eye_modulate: Color
var _base_sheen_position: Vector2
var _base_sheen_modulate: Color

func _ready() -> void:
	_cache_base_state()
	_build_animations()
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play(INTRO_NAME)

func _cache_base_state() -> void:
	_base_shadow_position = shadow.position
	_base_shadow_scale = shadow.scale
	_base_shadow_modulate = shadow.modulate

	_base_bots_position = bots.position

	_base_pewpew_position = pewpew.position
	_base_pewpew_rotation = pewpew.rotation

	_base_cable_rotation = cable_pivot.rotation
	_base_eye_modulate = eye_glow.modulate

	_base_sheen_position = sheen.position
	_base_sheen_modulate = sheen.modulate

func _build_animations() -> void:
	if anim_player.has_animation_library(""):
		anim_player.remove_animation_library("")

	var intro: Animation = _make_intro_animation()
	var idle: Animation = _make_idle_animation()
	var sheen_pass: Animation = _make_sheen_animation()

	var library := AnimationLibrary.new()
	library.add_animation(INTRO_NAME, intro)
	library.add_animation(IDLE_NAME, idle)
	library.add_animation(SHEEN_NAME, sheen_pass)

	anim_player.add_animation_library("", library)

func _make_intro_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_NONE

	_add_value_track(anim, ^"Bots:position", [
		{"time": 0.0, "value": _base_bots_position + Vector2(0.0, -34.0)},
		{"time": 0.68, "value": _base_bots_position + Vector2(0.0, 10.0)},
		{"time": 1.0, "value": _base_bots_position},
	])

	_add_value_track(anim, ^"PewPew:position", [
		{"time": 0.0, "value": _base_pewpew_position + Vector2(0.0, -54.0)},
		{"time": 0.62, "value": _base_pewpew_position + Vector2(0.0, 8.0)},
		{"time": 1.0, "value": _base_pewpew_position},
	])

	_add_value_track(anim, ^"Shadow:scale", [
		{"time": 0.0, "value": Vector2(0.92, 0.86)},
		{"time": 0.68, "value": Vector2(1.04, 1.02)},
		{"time": 1.0, "value": _base_shadow_scale},
	])

	_add_value_track(anim, ^"Shadow:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.30)},
		{"time": 0.70, "value": Color(1, 1, 1, 0.62)},
		{"time": 1.0, "value": _base_shadow_modulate},
	])

	_add_value_track(anim, ^"CablePivot:rotation", [
		{"time": 0.0, "value": -0.32},
		{"time": 0.42, "value": 0.10},
		{"time": 0.72, "value": -0.18},
		{"time": 1.0, "value": _base_cable_rotation},
	])

	_add_value_track(anim, ^"CablePivot/Head/EyeGlow:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.10)},
		{"time": 0.35, "value": Color(1, 1, 1, 1.00)},
		{"time": 0.60, "value": Color(1, 1, 1, 0.72)},
		{"time": 1.0, "value": _base_eye_modulate},
	])

	_add_value_track(anim, ^"PewPew:rotation", [
		{"time": 0.0, "value": 0.0},
		{"time": 0.74, "value": -0.012},
		{"time": 0.88, "value": 0.008},
		{"time": 1.0, "value": _base_pewpew_rotation},
	])

	return anim

func _make_idle_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 3.6
	anim.loop_mode = Animation.LOOP_LINEAR

	_add_value_track(anim, ^"CablePivot:rotation", [
		{"time": 0.0, "value": _base_cable_rotation},
		{"time": 0.9, "value": -0.05},
		{"time": 1.8, "value": -0.14},
		{"time": 2.7, "value": -0.08},
		{"time": 3.6, "value": _base_cable_rotation},
	])

	_add_value_track(anim, ^"CablePivot/Head/EyeGlow:modulate", [
		{"time": 0.0, "value": _base_eye_modulate},
		{"time": 0.55, "value": Color(1, 1, 1, 0.70)},
		{"time": 0.75, "value": Color(1, 1, 1, 0.96)},
		{"time": 1.10, "value": Color(1, 1, 1, 0.78)},
		{"time": 2.10, "value": Color(1, 1, 1, 0.88)},
		{"time": 2.25, "value": Color(1, 1, 1, 0.62)},
		{"time": 2.45, "value": Color(1, 1, 1, 0.92)},
		{"time": 3.6, "value": _base_eye_modulate},
	])

	_add_value_track(anim, ^"PewPew:position", [
		{"time": 0.0, "value": _base_pewpew_position},
		{"time": 1.2, "value": _base_pewpew_position + Vector2(0.0, -2.0)},
		{"time": 2.4, "value": _base_pewpew_position + Vector2(0.0, 1.0)},
		{"time": 3.6, "value": _base_pewpew_position},
	])

	_add_value_track(anim, ^"PewPew:rotation", [
		{"time": 0.0, "value": _base_pewpew_rotation},
		{"time": 1.8, "value": _base_pewpew_rotation - 0.004},
		{"time": 3.6, "value": _base_pewpew_rotation},
	])

	_add_value_track(anim, ^"Bots:position", [
		{"time": 0.0, "value": _base_bots_position},
		{"time": 1.8, "value": _base_bots_position + Vector2(0.0, 1.0)},
		{"time": 3.6, "value": _base_bots_position},
	])

	return anim

func _make_sheen_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 1.4
	anim.loop_mode = Animation.LOOP_NONE

	_add_value_track(anim, ^"SheenOverlay:position", [
		{"time": 0.0, "value": _base_sheen_position + Vector2(-220.0, 0.0)},
		{"time": 1.4, "value": _base_sheen_position + Vector2(220.0, 0.0)},
	])

	_add_value_track(anim, ^"SheenOverlay:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.18, "value": Color(1, 1, 1, 0.18)},
		{"time": 0.70, "value": Color(1, 1, 1, 0.26)},
		{"time": 1.18, "value": Color(1, 1, 1, 0.12)},
		{"time": 1.4, "value": _base_sheen_modulate},
	])

	return anim

func play_sheen_pass() -> void:
	if anim_player.current_animation == INTRO_NAME:
		return

	anim_player.play(SHEEN_NAME)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == INTRO_NAME:
		anim_player.play(IDLE_NAME)
	elif anim_name == SHEEN_NAME:
		anim_player.play(IDLE_NAME)

func _add_value_track(anim: Animation, path: NodePath, keys: Array[Dictionary]) -> void:
	var track: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, path)

	for key: Dictionary in keys:
		anim.track_insert_key(track, float(key["time"]), key["value"])
		
