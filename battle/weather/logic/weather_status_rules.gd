class_name WeatherStatusRules
extends RefCounted

const StatusApplicationScript = preload("res://mobile/status/status_application.gd")
const StatusSourceKindScript = preload("res://mobile/status/status_source_kind.gd")
const WeatherResourceValidationScript = preload("res://battle/weather/resources/weather_resource_validation.gd")
const WeatherStatusEffectScript = preload("res://battle/weather/resources/weather_status_effect.gd")

static func build_turn_start_status_applications(state: WeatherRuntimeState, controller, battle_system) -> Array:
	var applications: Array = []
	if state == null or controller == null or battle_system == null:
		return applications
	for effect in _get_turn_start_status_effects(state):
		for unit in effect.get_turn_start_targets(controller, battle_system):
			if unit != null and is_instance_valid(unit):
				applications.append(_make_status_application(state, effect, unit))
	return applications

static func build_impact_status_applications(
	state: WeatherRuntimeState,
	event: ImpactEvent,
	battle_system,
	splash_radius: float = -1.0
) -> Array:
	var applications: Array = []
	if state == null or event == null or battle_system == null:
		return applications
	for effect in _get_impact_status_effects(state):
		for unit in effect.get_impact_targets(event, battle_system, splash_radius):
			if unit != null and is_instance_valid(unit):
				applications.append(_make_status_application(state, effect, unit, event.team_index, event.shooter_id))
	return applications

static func _get_turn_start_status_effects(state: WeatherRuntimeState) -> Array:
	if state == null or state.active_event == null or state.active_event.definition == null:
		return []
	return _filter_status_effects(state.active_event.definition.turn_start_status_effects)

static func _get_impact_status_effects(state: WeatherRuntimeState) -> Array:
	if state == null or state.active_event == null or state.active_event.definition == null:
		return []
	return _filter_status_effects(state.active_event.definition.impact_status_effects)

static func _filter_status_effects(effects: Array) -> Array:
	var filtered: Array = []
	for effect in effects:
		if WeatherResourceValidationScript.matches_script(effect, WeatherStatusEffectScript):
			filtered.append(effect)
	return filtered

static func _make_status_application(
	state: WeatherRuntimeState,
	effect,
	target_mobile,
	source_team_index: int = -1,
	applier_id: String = ""
):
	if effect == null or target_mobile == null:
		return null
	var source_id: String = effect.source_id_override
	if source_id == "" and state != null and state.active_event != null and state.active_event.definition != null:
		source_id = (
			state.active_event.definition.resource_path
			if state.active_event.definition.resource_path != ""
			else state.active_event.definition.display_name
		)
	return StatusApplicationScript.new(
		effect.status_definition,
		StatusSourceKindScript.WEATHER,
		source_id,
		effect.duration_turns,
		effect.stacks,
		source_team_index,
		applier_id,
		target_mobile
	)
