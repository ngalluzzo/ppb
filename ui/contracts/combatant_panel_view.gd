class_name CombatantPanelView
extends RefCounted

var combatant_id: String = ""
var display_name: String = ""
var angle_text: String = ""
var power_text: String = ""
var thrust_text: String = ""
var shot_slot_text: String = ""
var can_fire: bool = false
var can_control: bool = false
var metrics: Array[MetricView] = []
var status_badges: Array = []
