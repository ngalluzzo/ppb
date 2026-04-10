extends Control

signal start_requested

const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const ActionItemViewScript = preload("res://ui/contracts/action_item_view.gd")
const HeroTitleStackScript = preload("res://ui/composed/title/hero_title_stack.gd")
const TitleMenuRailScript = preload("res://ui/composed/title/title_menu_rail.gd")
const AmbientInfoFooterScript = preload("res://ui/composed/title/ambient_info_footer.gd")

@onready var bg_sky: TextureRect = $BackgroundSky
@onready var bg_hills: TextureRect = $BackgroundHills
@onready var ground: TextureRect = $Ground
@onready var logo: Control = $CenterWrap/LogoAnchor/PewPewBotsLogo
@onready var legacy_subtitle: Label = $CenterWrap/Subtitle
@onready var legacy_press_any_key: Label = $CenterWrap/PressAnyKey
@onready var center_wrap: Control = $CenterWrap
@onready var vignette: TextureRect = $Vignette
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sheen_timer: Timer = $SheenTimer
@onready var input_cooldown: Timer = $InputCooldown

const INTRO_NAME: StringName = &"intro"
const IDLE_NAME: StringName = &"idle"
const START_NAME: StringName = &"start_transition"

var _can_accept_input: bool = false
var _starting: bool = false

var _base_bg_sky_position: Vector2
var _base_bg_sky_modulate: Color
var _base_bg_hills_position: Vector2
var _base_bg_hills_modulate: Color
var _base_ground_position: Vector2
var _base_ground_modulate: Color
var _base_logo_position: Vector2
var _base_logo_scale: Vector2
var _base_logo_modulate: Color
var _base_subtitle_modulate: Color
var _base_press_any_key_modulate: Color
var _base_vignette_modulate: Color
var _base_menu_modulate: Color

var _hero_stack: HeroTitleStack
var _subtitle_label: Label
var _prompt_label: Label
var _menu_rail: TitleMenuRail
var _ambient_footer: AmbientInfoFooter

func _ready() -> void:
	AppUIScript.apply_theme(self, AppUIScript.Scope.RUNTIME)
	_build_composed_ui()
	_cache_base_state()
	_build_animations()

	anim_player.animation_finished.connect(_on_animation_finished)
	sheen_timer.timeout.connect(_on_sheen_timer_timeout)
	input_cooldown.timeout.connect(_on_input_cooldown_timeout)

	anim_player.play(INTRO_NAME)

func _cache_base_state() -> void:
	_base_bg_sky_position = bg_sky.position
	_base_bg_sky_modulate = bg_sky.modulate

	_base_bg_hills_position = bg_hills.position
	_base_bg_hills_modulate = bg_hills.modulate

	_base_ground_position = ground.position
	_base_ground_modulate = ground.modulate

	_base_logo_position = logo.position
	_base_logo_scale = logo.scale
	_base_logo_modulate = logo.modulate

	_base_subtitle_modulate = _subtitle_label.modulate
	_base_press_any_key_modulate = _prompt_label.modulate
	_base_vignette_modulate = vignette.modulate
	_base_menu_modulate = _menu_rail.modulate

func _unhandled_input(event: InputEvent) -> void:
	if not _can_accept_input:
		return
	if _starting:
		return

	var pressed := false

	if event is InputEventKey and event.pressed and not event.echo:
		pressed = true
	elif event is InputEventMouseButton and event.pressed:
		pressed = true
	elif event is InputEventJoypadButton and event.pressed:
		pressed = true

	if pressed:
		_begin_start_transition()

func _build_animations() -> void:
	if anim_player.has_animation_library(""):
		anim_player.remove_animation_library("")

	var intro: Animation = _make_intro_animation()
	var idle: Animation = _make_idle_animation()
	var start_transition: Animation = _make_start_transition_animation()

	var library := AnimationLibrary.new()
	library.add_animation(INTRO_NAME, intro)
	library.add_animation(IDLE_NAME, idle)
	library.add_animation(START_NAME, start_transition)

	anim_player.add_animation_library("", library)

func _make_intro_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 1.4
	anim.loop_mode = Animation.LOOP_NONE

	_add_value_track(anim, ^"BackgroundSky:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.9, "value": _base_bg_sky_modulate},
		{"time": 1.4, "value": _base_bg_sky_modulate},
	])

	_add_value_track(anim, ^"BackgroundHills:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.0, "value": _base_bg_hills_modulate},
		{"time": 1.4, "value": _base_bg_hills_modulate},
	])

	_add_value_track(anim, ^"Ground:position", [
		{"time": 0.0, "value": _base_ground_position + Vector2(0.0, 24.0)},
		{"time": 1.4, "value": _base_ground_position},
	])

	_add_value_track(anim, ^"Ground:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.95, "value": _base_ground_modulate},
		{"time": 1.4, "value": _base_ground_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/LogoAnchor/PewPewBotsLogo:position", [
		{"time": 0.0, "value": _base_logo_position + Vector2(0.0, -20.0)},
		{"time": 1.4, "value": _base_logo_position},
	])

	_add_value_track(anim, ^"CenterWrap/LogoAnchor/PewPewBotsLogo:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.45, "value": Color(1, 1, 1, 0.55)},
		{"time": 1.0, "value": _base_logo_modulate},
		{"time": 1.4, "value": _base_logo_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Subtitle:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.9, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.2, "value": _base_subtitle_modulate},
		{"time": 1.4, "value": _base_subtitle_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Prompt:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.25, "value": _base_press_any_key_modulate},
		{"time": 1.4, "value": _base_press_any_key_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/MenuRail:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.05, "value": Color(1, 1, 1, 0.0)},
		{"time": 1.4, "value": _base_menu_modulate},
	])

	_add_value_track(anim, ^"Vignette:modulate", [
		{"time": 0.0, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.8, "value": _base_vignette_modulate},
		{"time": 1.4, "value": _base_vignette_modulate},
	])

	return anim

func _make_idle_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 3.2
	anim.loop_mode = Animation.LOOP_LINEAR

	_add_value_track(anim, ^"BackgroundHills:position", [
		{"time": 0.0, "value": _base_bg_hills_position},
		{"time": 1.6, "value": _base_bg_hills_position + Vector2(-6.0, 0.0)},
		{"time": 3.2, "value": _base_bg_hills_position},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Subtitle:modulate", [
		{"time": 0.0, "value": _base_subtitle_modulate},
		{"time": 1.6, "value": Color(1, 1, 1, 0.74)},
		{"time": 3.2, "value": _base_subtitle_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Prompt:modulate", [
		{"time": 0.0, "value": _base_press_any_key_modulate},
		{"time": 0.9, "value": Color(1, 1, 1, 0.52)},
		{"time": 1.4, "value": _base_press_any_key_modulate},
		{"time": 2.4, "value": Color(1, 1, 1, 0.64)},
		{"time": 3.2, "value": _base_press_any_key_modulate},
	])

	_add_value_track(anim, ^"CenterWrap/LogoAnchor/PewPewBotsLogo:position", [
		{"time": 0.0, "value": _base_logo_position},
		{"time": 1.6, "value": _base_logo_position + Vector2(0.0, -3.0)},
		{"time": 3.2, "value": _base_logo_position},
	])

	return anim

func _make_start_transition_animation() -> Animation:
	var anim := Animation.new()
	anim.length = 0.55
	anim.loop_mode = Animation.LOOP_NONE

	_add_value_track(anim, ^"CenterWrap/LogoAnchor/PewPewBotsLogo:scale", [
		{"time": 0.0, "value": _base_logo_scale},
		{"time": 0.22, "value": _base_logo_scale + Vector2(0.025, 0.025)},
		{"time": 0.55, "value": _base_logo_scale + Vector2(0.12, 0.12)},
	])

	_add_value_track(anim, ^"CenterWrap/LogoAnchor/PewPewBotsLogo:modulate", [
		{"time": 0.0, "value": _base_logo_modulate},
		{"time": 0.55, "value": Color(1, 1, 1, 0.0)},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Subtitle:modulate", [
		{"time": 0.0, "value": _base_subtitle_modulate},
		{"time": 0.3, "value": Color(1, 1, 1, 0.1)},
		{"time": 0.55, "value": Color(1, 1, 1, 0.0)},
	])

	_add_value_track(anim, ^"CenterWrap/HeroStack/Prompt:modulate", [
		{"time": 0.0, "value": _base_press_any_key_modulate},
		{"time": 0.12, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.22, "value": _base_press_any_key_modulate},
		{"time": 0.32, "value": Color(1, 1, 1, 0.0)},
		{"time": 0.55, "value": Color(1, 1, 1, 0.0)},
	])

	_add_value_track(anim, ^"CenterWrap/MenuRail:modulate", [
		{"time": 0.0, "value": _base_menu_modulate},
		{"time": 0.55, "value": Color(1, 1, 1, 0.0)},
	])

	_add_value_track(anim, ^"Vignette:modulate", [
		{"time": 0.0, "value": _base_vignette_modulate},
		{"time": 0.55, "value": Color(1, 1, 1, 1.0)},
	])

	return anim

func _begin_start_transition() -> void:
	_starting = true
	_can_accept_input = false
	sheen_timer.stop()
	anim_player.play(START_NAME)

func _on_sheen_timer_timeout() -> void:
	if _starting:
		return
	if logo.has_method("play_sheen_pass"):
		logo.call("play_sheen_pass")

func _on_input_cooldown_timeout() -> void:
	_can_accept_input = true

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == INTRO_NAME:
		anim_player.play(IDLE_NAME)
	elif anim_name == START_NAME:
		emit_signal("start_requested")

func _build_composed_ui() -> void:
	legacy_subtitle.visible = false
	legacy_press_any_key.visible = false

	_hero_stack = HeroTitleStackScript.new()
	_hero_stack.name = "HeroStack"
	_hero_stack.scope = AppUIScript.Scope.RUNTIME
	_hero_stack.anchors_preset = PRESET_CENTER_TOP
	_hero_stack.anchor_left = 0.5
	_hero_stack.anchor_top = 0.0
	_hero_stack.anchor_right = 0.5
	_hero_stack.anchor_bottom = 0.0
	_hero_stack.offset_left = -360.0
	_hero_stack.offset_top = 760.0
	_hero_stack.offset_right = 360.0
	_hero_stack.offset_bottom = 920.0
	center_wrap.add_child(_hero_stack)
	_hero_stack.set_subtitle_text("WORMS / GUNBOUND REINVENTED")
	_hero_stack.set_prompt_text("PRESS ANY KEY")
	_subtitle_label = _hero_stack.get_subtitle_label()
	_prompt_label = _hero_stack.get_prompt_label()

	_menu_rail = TitleMenuRailScript.new()
	_menu_rail.name = "MenuRail"
	_menu_rail.scope = AppUIScript.Scope.RUNTIME
	_menu_rail.anchors_preset = PRESET_CENTER_TOP
	_menu_rail.anchor_left = 0.5
	_menu_rail.anchor_top = 0.0
	_menu_rail.anchor_right = 0.5
	_menu_rail.anchor_bottom = 0.0
	_menu_rail.offset_left = -120.0
	_menu_rail.offset_top = 930.0
	_menu_rail.offset_right = 120.0
	_menu_rail.offset_bottom = 1010.0
	_menu_rail.modulate = Color(1, 1, 1, 0.92)
	center_wrap.add_child(_menu_rail)
	_menu_rail.set_actions([
		ActionItemViewScript.new(&"start", "Start", "Begin the match flow.", null, &"primary", true, true, "Any Key"),
	])
	_menu_rail.action_pressed.connect(_on_menu_action_pressed)

	_ambient_footer = AmbientInfoFooterScript.new()
	_ambient_footer.name = "AmbientFooter"
	_ambient_footer.scope = AppUIScript.Scope.RUNTIME
	_ambient_footer.anchors_preset = PRESET_CENTER_BOTTOM
	_ambient_footer.anchor_left = 0.5
	_ambient_footer.anchor_top = 1.0
	_ambient_footer.anchor_right = 0.5
	_ambient_footer.anchor_bottom = 1.0
	_ambient_footer.offset_left = -420.0
	_ambient_footer.offset_top = -48.0
	_ambient_footer.offset_right = 420.0
	_ambient_footer.offset_bottom = -12.0
	_ambient_footer.set_info("v0", "Mouse / Keyboard / Gamepad", "Local")
	add_child(_ambient_footer)

func _on_menu_action_pressed(_id: StringName) -> void:
	if _can_accept_input and not _starting:
		_begin_start_transition()

func _add_value_track(anim: Animation, path: NodePath, keys: Array[Dictionary]) -> void:
	var track: int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, path)

	for key: Dictionary in keys:
		anim.track_insert_key(track, float(key["time"]), key["value"])
