@tool
class_name ShotPreviewLauncher
extends RefCounted

const MobileScene = preload("res://mobile/mobile.tscn")
const CannonScene = preload("res://weapon/cannon/cannon.tscn")

func spawn_actor(session: ShotPreviewSession, battle_system: BattleSystem) -> Dictionary:
	var bounds := battle_system.editor_preview_bounds
	var floor_y := battle_system.editor_preview_floor_y
	var facing := session.overrides.facing_direction if session.overrides != null else 1
	var shooter_id := session.bundle.get_display_name().to_snake_case() if session != null and session.bundle != null else "preview_shooter"
	var team_index := 0
	var anchor_x := bounds.position.x + 200.0 if facing >= 0 else bounds.end.x - 200.0
	if session.uses_mobile_actor():
		var mobile := MobileScene.instantiate() as Mobile
		mobile.mobile_def = session.get_preview_mobile_definition()
		mobile.facing_direction = facing
		mobile.combatant_id = shooter_id
		mobile.team_index = team_index
		mobile.position = Vector2(anchor_x, floor_y - mobile.mobile_def.body_size.y * 0.55)
		battle_system.get_world_root().add_child(mobile)
		mobile.set_deferred("collision_layer", 0)
		mobile.set_deferred("collision_mask", 0)
		var preview_shape := mobile.get_node_or_null("Shape") as CollisionShape2D
		if preview_shape != null:
			preview_shape.set_deferred("disabled", true)
		_configure_cannon(mobile.cannon, session)
		return {"node": mobile, "cannon": mobile.cannon}
	var cannon := CannonScene.instantiate() as Cannon
	cannon.cannon_def = session.get_preview_cannon_definition()
	cannon.facing_direction = facing
	cannon.position = Vector2(anchor_x, floor_y - 96.0)
	battle_system.get_world_root().add_child(cannon)
	_configure_cannon(cannon, session)
	return {"node": cannon, "cannon": cannon}

func build_shot_event(session: ShotPreviewSession, cannon: Cannon, weather_controller: WeatherController) -> ShotEvent:
	if session == null or cannon == null or session.overrides == null:
		return null
	var command := FireCommand.new(
		"",
		session.get_preview_slot(),
		session.overrides.angle,
		session.overrides.power,
		Engine.get_process_frames()
	)
	return cannon.build_editor_preview_shot_event(command, weather_controller)

func _configure_cannon(cannon: Cannon, session: ShotPreviewSession) -> void:
	if cannon == null or session == null or session.overrides == null:
		return
	cannon.editor_preview_enabled = true
	cannon.editor_preview_shot_pattern = session.overrides.shot_pattern
	cannon.editor_preview_slot = session.get_preview_slot()
	cannon.editor_preview_power = session.overrides.power
	cannon.editor_preview_shooter_id = session.bundle.get_display_name().to_snake_case()
	cannon.editor_preview_team_index = 0
	cannon.editor_preview_facing_direction = session.overrides.facing_direction
	cannon.set_elevation_degrees(session.overrides.angle)
