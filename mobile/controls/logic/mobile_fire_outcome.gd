class_name MobileFireOutcome
extends RefCounted

var event: ShotEvent
var charge_canceled: bool = false
var next_state: MobileControllerState

func _init(
	p_event: ShotEvent = null,
	p_charge_canceled: bool = false,
	p_next_state: MobileControllerState = null
) -> void:
	event = p_event
	charge_canceled = p_charge_canceled
	next_state = p_next_state
