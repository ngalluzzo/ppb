class_name BattleTurnEffects
extends RefCounted

static func apply_turn_start(
	active_controller: MobileController,
	battle_system: BattleSystem,
	weather_controller,
	turn_index: int
) -> void:
	if weather_controller != null:
		weather_controller.on_turn_started(turn_index)
	if active_controller != null:
		var target_context := active_controller.get_target_context()
		if target_context != null and target_context.mobile != null and target_context.mobile.status_controller != null:
			target_context.mobile.status_controller.tick_turn_start()
	if weather_controller == null or battle_system == null:
		return
	var applications: Array = weather_controller.build_turn_start_status_applications(active_controller, battle_system)
	for application in applications:
		if application == null or application.target_mobile == null:
			continue
		var mobile = application.target_mobile
		if not is_instance_valid(mobile) or mobile.status_controller == null:
			continue
		mobile.status_controller.apply_status(application)
