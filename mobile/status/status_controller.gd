class_name StatusController
extends RefCounted

const StatusDefinitionScript = preload("res://mobile/status/status_definition.gd")
const StatusInstanceScript = preload("res://mobile/status/status_instance.gd")
const StatusViewStateScript = preload("res://mobile/status/status_view_state.gd")
const ResourceValidationScript = preload("res://shared/resource_validation.gd")

signal statuses_changed
signal status_applied(instance: StatusInstance)
signal status_removed(instance: StatusInstance)

var _stat_container: StatContainer
var _active_statuses: Array[StatusInstance] = []

func setup(stat_container: StatContainer) -> void:
	_stat_container = stat_container

func apply_status(application: StatusApplication) -> void:
	if application == null or _stat_container == null:
		return
	var definition = ResourceValidationScript.require_resource(
		application.status_definition,
		StatusDefinitionScript,
		"StatusDefinition",
		"StatusController.apply_status(status_definition)"
	)
	if definition == null:
		return
	var duration: int = application.duration_turns if application.duration_turns > 0 else definition.duration_turns
	var same_source := _find_same_source_status(definition, application.source_kind, application.source_id)
	if same_source != null:
		same_source.remaining_turns = maxi(1, duration)
		same_source.stacks = _resolve_reapplied_stacks(definition, same_source.stacks, application.stacks)
		_rebuild_runtime_modifiers(same_source)
		status_applied.emit(same_source)
		statuses_changed.emit()
		return

	var existing := _find_status_by_definition(definition)
	if existing != null and definition.stack_policy == StatusDefinition.StackPolicy.REFRESH:
		existing.remaining_turns = maxi(1, duration)
		_rebuild_runtime_modifiers(existing)
		status_applied.emit(existing)
		statuses_changed.emit()
		return
	var instance: StatusInstance = StatusInstanceScript.new(
		definition,
		maxi(1, duration),
		mini(maxi(1, application.stacks), maxi(1, definition.max_stacks)),
		application.source_kind,
		application.source_id,
		application.team_index,
		application.applier_id
	)
	_active_statuses.append(instance)
	_rebuild_runtime_modifiers(instance)
	status_applied.emit(instance)
	statuses_changed.emit()

func remove_status_by_tag(tag: String) -> void:
	var removed_any := false
	for index in range(_active_statuses.size() - 1, -1, -1):
		var instance := _active_statuses[index]
		if instance == null or not instance.has_tag(tag):
			continue
		_detach_runtime_modifiers(instance)
		_active_statuses.remove_at(index)
		status_removed.emit(instance)
		removed_any = true
	if removed_any:
		statuses_changed.emit()

func tick_turn_start() -> void:
	var removed_any := false
	for index in range(_active_statuses.size() - 1, -1, -1):
		var instance := _active_statuses[index]
		if instance == null:
			_active_statuses.remove_at(index)
			removed_any = true
			continue
		instance.remaining_turns -= 1
		if instance.remaining_turns > 0:
			continue
		_detach_runtime_modifiers(instance)
		_active_statuses.remove_at(index)
		status_removed.emit(instance)
		removed_any = true
	if removed_any:
		statuses_changed.emit()

func tick_turn_end() -> void:
	pass

func get_active_statuses() -> Array[StatusInstance]:
	return _active_statuses.duplicate()

func get_status_view_states() -> Array:
	var states: Array = []
	for instance in _active_statuses:
		if instance == null or instance.definition == null:
			continue
		states.append(_build_view_state(instance))
	return states

func _find_same_source_status(definition: Resource, source_kind: StringName, source_id: String) -> StatusInstance:
	for instance in _active_statuses:
		if instance == null:
			continue
		if instance.definition == definition and instance.source_kind == source_kind and instance.source_id == source_id:
			return instance
	return null

func _find_status_by_definition(definition: Resource) -> StatusInstance:
	for instance in _active_statuses:
		if instance != null and instance.definition == definition:
			return instance
	return null

func _rebuild_runtime_modifiers(instance: StatusInstance) -> void:
	_detach_runtime_modifiers(instance)
	if instance == null or instance.definition == null or _stat_container == null:
		return
	for modifier_template in instance.definition.modifiers:
		if modifier_template == null:
			continue
		var modifier := modifier_template.duplicate(true) as StatModifier
		if modifier == null:
			continue
		modifier.amount *= instance.stacks
		instance.runtime_modifiers.append(modifier)
		_stat_container.add_runtime_modifier(modifier)

func _detach_runtime_modifiers(instance: StatusInstance) -> void:
	if instance == null or _stat_container == null:
		return
	for modifier in instance.runtime_modifiers:
		if modifier != null:
			_stat_container.remove_runtime_modifier(modifier)
	instance.runtime_modifiers.clear()

func _build_view_state(instance: StatusInstance):
	var definition = instance.definition
	return StatusViewStateScript.new(
		definition.display_name,
		_resolve_short_label(definition),
		definition.icon,
		definition.tint,
		definition.polarity,
		definition.priority,
		instance.remaining_turns,
		instance.stacks,
		definition.description
	)

func _resolve_reapplied_stacks(definition: Resource, current_stacks: int, incoming_stacks: int) -> int:
	var clamped_incoming := maxi(1, incoming_stacks)
	var max_stacks := maxi(1, definition.max_stacks)
	if definition.stack_policy == StatusDefinition.StackPolicy.STACK:
		return mini(max_stacks, current_stacks + clamped_incoming)
	return mini(max_stacks, maxi(current_stacks, clamped_incoming))

func _resolve_short_label(definition: Resource) -> String:
	if definition == null:
		return ""
	var explicit_label: String = String(definition.short_label).strip_edges()
	if explicit_label != "":
		return explicit_label.substr(0, 3).to_upper()
	var words: PackedStringArray = String(definition.display_name).split(" ", false)
	var initials := ""
	for word in words:
		if word == "":
			continue
		initials += word[0]
		if initials.length() >= 3:
			break
	if initials != "":
		return initials.to_upper()
	return definition.display_name.substr(0, min(3, definition.display_name.length())).to_upper()
