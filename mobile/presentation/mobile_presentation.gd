class_name MobilePresentation
extends RefCounted

enum BodyAnimationAction {
	NONE,
	RESTORE_LOCOMOTION,
	FREE_OWNER
}

const BODY_ANIMATIONS = [
	{"name": "idle",   "fps": 6,  "loop": true,  "frames": 4},
	{"name": "walk",   "fps": 12, "loop": true,  "frames": 6},
	{"name": "aim",    "fps": 4,  "loop": true,  "frames": 4},
	{"name": "charge", "fps": 8,  "loop": true,  "frames": 4},
	{"name": "fire",   "fps": 12, "loop": false, "frames": 4},
	{"name": "hit",    "fps": 12, "loop": false, "frames": 3},
	{"name": "die",    "fps": 10, "loop": false, "frames": 8},
]

const CANNON_ANIMATIONS = [
	{"name": "idle",   "fps": 1,  "loop": true,  "frames": 2},
	{"name": "charge", "fps": 8,  "loop": true,  "frames": 4},
	{"name": "fire",   "fps": 16, "loop": false, "frames": 4},
]

var _body: AnimatedSprite2D
var _barrel: AnimatedSprite2D
var _mobile_def: MobileDefinition

func setup(body: AnimatedSprite2D, barrel: AnimatedSprite2D, mobile_def: MobileDefinition) -> void:
	_body = body
	_barrel = barrel
	_mobile_def = mobile_def
	_apply_sprite_frames()

func apply_facing(facing_direction: int) -> void:
	if _body != null:
		_body.flip_h = facing_direction < 0

func play_idle() -> void:
	_play_if_available(_body, "idle")
	_play_if_available(_barrel, "idle")

func on_started_charging() -> void:
	_play_if_available(_body, "charge")
	_play_if_available(_barrel, "charge")

func on_charge_canceled(grounded: bool, moving: bool) -> void:
	update_locomotion_animation(grounded, moving)

func on_fired() -> void:
	_play_if_available(_body, "fire")
	_play_if_available(_barrel, "fire")

func on_hit() -> void:
	_play_if_available(_body, "hit")

func on_died() -> void:
	_play_if_available(_body, "die")
	_play_if_available(_barrel, "idle")

func handle_body_animation_finished() -> int:
	if _body == null:
		return BodyAnimationAction.NONE
	match _body.animation:
		"fire", "hit":
			return BodyAnimationAction.RESTORE_LOCOMOTION
		"die":
			return BodyAnimationAction.FREE_OWNER
		_:
			return BodyAnimationAction.NONE

func handle_barrel_animation_finished() -> void:
	if _barrel == null:
		return
	if _barrel.animation == "fire":
		_play_if_available(_barrel, "idle")

func update_locomotion_animation(grounded: bool, moving: bool) -> void:
	if _body == null or _barrel == null:
		return
	if _body.animation in ["charge", "fire", "hit", "die"]:
		return
	if grounded and moving:
		if _body.animation != "walk":
			_play_if_available(_body, "walk")
	else:
		if _body.animation != "idle":
			_play_if_available(_body, "idle")
	if _barrel.animation == "charge":
		return
	if _barrel.animation not in ["fire"] and _barrel.animation != "idle":
		_play_if_available(_barrel, "idle")

func build_traversal_debug_text(state: MobilePhysicsState, mobile_def: MobileDefinition, floor_angle_deg: float, walkable: bool) -> String:
	var step_state := "success" if state.step_succeeded else ("attempt" if state.step_attempted else "idle")
	return "traversal: %s | grounded=%s | floor=%.1fdeg / max=%.1fdeg | step=%s@%.1f" % [
		"walkable" if walkable else "blocked",
		"yes" if state.grounded else "no",
		floor_angle_deg,
		mobile_def.max_walkable_slope_degrees if mobile_def != null else 40.0,
		step_state,
		mobile_def.step_height if mobile_def != null else 0.0
	]

func _apply_sprite_frames() -> void:
	if _mobile_def == null or _mobile_def.sprite_path == "" or _body == null or _barrel == null:
		return
	var mobile_name := _get_sprite_stem()
	_body.sprite_frames = _build_sprite_frames(
		_mobile_def.sprite_path + mobile_name + "_body_",
		BODY_ANIMATIONS,
		Vector2i(48, 48)
	)
	_barrel.sprite_frames = _build_sprite_frames(
		_mobile_def.sprite_path + mobile_name + "_cannon_",
		CANNON_ANIMATIONS,
		Vector2i(32, 32)
	)

func _build_sprite_frames(prefix: String, animations: Array, frame_size: Vector2i) -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	for anim in animations:
		frames.add_animation(anim.name)
		frames.set_animation_loop(anim.name, anim.loop)
		frames.set_animation_speed(anim.name, anim.fps)
		var texture: Texture2D = load(prefix + anim.name + ".png")
		if texture == null:
			push_warning("Missing sprite: " + prefix + anim.name + ".png")
			continue
		var available_frames := maxi(1, texture.get_width() / max(1, frame_size.x))
		var frame_total := mini(int(anim.frames), available_frames)
		for i in frame_total:
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
			frames.add_frame(anim.name, atlas)
	return frames

func _get_sprite_stem() -> String:
	if _mobile_def == null:
		return ""
	var explicit_stem := _mobile_def.sprite_stem.strip_edges()
	if explicit_stem != "":
		return explicit_stem
	return _mobile_def.name.to_lower()

func _play_if_available(sprite: AnimatedSprite2D, animation_name: StringName) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if sprite.sprite_frames.has_animation(String(animation_name)):
		sprite.play(animation_name)
