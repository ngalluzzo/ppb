class_name StatContainer
extends Node

signal health_changed(current: float, maximum: float)
signal died
signal hit

@export var stat_def: StatDefinition

var current_health: float
var _modifiers: Array[StatModifier] = []
var _runtime_modifiers: Array[StatModifier] = []

func _ready() -> void:
	if stat_def == null:
		return
	current_health = stat_def.max_health

func take_damage(raw_amount: float) -> void:
	var final_amount = _resolve_damage(raw_amount)
	current_health = max(0.0, current_health - final_amount)
	emit_signal("health_changed", current_health, get_max_health())
	emit_signal("hit")
	if current_health <= 0.0:
		emit_signal("died")

func heal(amount: float) -> void:
	current_health = min(get_max_health(), current_health + amount)
	emit_signal("health_changed", current_health, get_max_health())

func get_stat(stat: String) -> float:
	var base = _get_base_stat(stat)
	return _apply_modifiers(stat, base)

func add_modifier(modifier: StatModifier) -> void:
	_modifiers.append(modifier)

func remove_modifier(modifier: StatModifier) -> void:
	_modifiers.erase(modifier)

func add_runtime_modifier(modifier: StatModifier) -> void:
	_runtime_modifiers.append(modifier)

func remove_runtime_modifier(modifier: StatModifier) -> void:
	_runtime_modifiers.erase(modifier)

func get_max_health() -> float:
	return get_stat("max_health")

func _resolve_damage(raw_amount: float) -> float:
	var armor = get_stat("armor")
	var damage_taken_mult = get_stat("damage_taken")
	var after_armor = max(0.0, raw_amount - armor)
	return after_armor * damage_taken_mult

func _get_base_stat(stat: String) -> float:
	if stat_def == null:
		return 0.0
	match stat:
		"max_health":   return stat_def.max_health
		"armor":        return stat_def.armor
		"weight":       return stat_def.weight
		"thrust":       return stat_def.thrust
		"damage_taken": return 1.0
		"damage_dealt": return 1.0
	return 0.0

func _apply_modifiers(stat: String, base: float) -> float:
	var flat_total: float = 0.0
	var percent_total: float = 1.0
	for mod in _modifiers:
		if mod.stat != stat:
			continue
		if mod.application_mode == StatModifier.ApplicationMode.PERSISTENT:
			match mod.modifier_type:
				StatModifier.ModifierType.FLAT:
					flat_total += mod.amount
				StatModifier.ModifierType.PERCENT:
					percent_total += mod.amount
	for mod in _runtime_modifiers:
		if mod == null or mod.stat != stat:
			continue
		match mod.modifier_type:
			StatModifier.ModifierType.FLAT:
				flat_total += mod.amount
			StatModifier.ModifierType.PERCENT:
				percent_total += mod.amount
	return (base + flat_total) * percent_total
