extends SceneTree

const StatusApplicationScript = preload("res://mobile/status/status_application.gd")
const StatusControllerScript = preload("res://mobile/status/status_controller.gd")
const WeatherControllerScript = preload("res://battle/weather/weather_controller.gd")

class DummyMobile:
	extends RefCounted
	var team_index: int = 0
	var combatant_id: String = ""

	func _init(p_team_index: int = 0, p_combatant_id: String = "") -> void:
		team_index = p_team_index
		combatant_id = p_combatant_id

class DummyController:
	extends RefCounted
	var mobile

	func _init(p_mobile) -> void:
		mobile = p_mobile

	func get_target_context():
		return DummyTargetContext.new(mobile)

class DummyTargetContext:
	extends RefCounted
	var mobile
	var team_index: int = -1
	var combatant_id: String = ""

	func _init(p_mobile) -> void:
		mobile = p_mobile
		team_index = mobile.team_index if mobile != null else -1
		combatant_id = mobile.combatant_id if mobile != null else ""

class DummyBattleSystem:
	extends RefCounted
	var _units: Array = []

	func _init(p_units: Array = []) -> void:
		_units = p_units

	func get_units() -> Array:
		return _units

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mobile_def: MobileDefinition = load("res://roster/mobiles/ironclad/ironclad_mobile_definition.tres")
	var stat_container := StatContainer.new()
	stat_container.stat_def = mobile_def.stat_def
	root.add_child(stat_container)

	var status_controller = StatusControllerScript.new()
	status_controller.setup(stat_container)

	var base_thrust := stat_container.get_stat("thrust")
	var base_damage_dealt := stat_container.get_stat("damage_dealt")
	var mired: Resource = load("res://roster/statuses/mired.tres")
	var charged: Resource = load("res://roster/statuses/charged.tres")
	var stacked_definition := StatusDefinition.new()
	stacked_definition.display_name = "Stack Probe"
	stacked_definition.stack_policy = StatusDefinition.StackPolicy.STACK
	stacked_definition.max_stacks = 3
	var stacked_modifier := StatModifier.new()
	stacked_modifier.stat = "damage_dealt"
	stacked_modifier.modifier_type = StatModifier.ModifierType.PERCENT
	stacked_modifier.amount = 0.1
	stacked_definition.modifiers = [stacked_modifier]

	status_controller.apply_status(StatusApplicationScript.new(mired, &"weather", "heavy_air", 1, 1))
	var mired_thrust := stat_container.get_stat("thrust")
	status_controller.tick_turn_start()
	var restored_thrust := stat_container.get_stat("thrust")

	status_controller.apply_status(StatusApplicationScript.new(charged, &"weather", "storm_charge", 1, 1))
	var charged_damage_dealt := stat_container.get_stat("damage_dealt")
	status_controller.apply_status(StatusApplicationScript.new(stacked_definition, &"probe", "same_source", 2, 1))
	status_controller.apply_status(StatusApplicationScript.new(stacked_definition, &"probe", "same_source", 2, 1))
	var stacked_damage_dealt := stat_container.get_stat("damage_dealt")

	var weather_config: Resource = load("res://roster/weather/match_weather_default.tres")
	var weather_controller = WeatherControllerScript.new()
	root.add_child(weather_controller)
	weather_controller.setup(weather_config, 424242)
	weather_controller.on_turn_started(0)

	var dummy_mobile = DummyMobile.new(0, "probe_unit")
	var turn_start_apps: Array = weather_controller.build_turn_start_status_applications(
		DummyController.new(dummy_mobile),
		DummyBattleSystem.new([dummy_mobile])
	)
	var application_names: Array[String] = []
	for application in turn_start_apps:
		if application != null and application.status_definition != null:
			application_names.append(application.status_definition.display_name)

	print("--- status probe ---")
	print(
		"thrust base=%s mired=%s restored=%s damage_dealt base=%s charged=%s stacked=%s" % [
			base_thrust,
			mired_thrust,
			restored_thrust,
			base_damage_dealt,
			charged_damage_dealt,
			stacked_damage_dealt
		]
	)
	print(
		"weather active=%s turn_start_statuses=%s" % [
			weather_controller.get_weather_state().active_event.definition.display_name,
			application_names
		]
	)

	quit()
