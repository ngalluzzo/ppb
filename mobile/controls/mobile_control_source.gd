class_name MobileControlSource
extends RefCounted

func gather_intent(snapshot: MobileControlSourceSnapshot, _delta: float) -> MobileIntent:
	if snapshot == null:
		return MobileIntent.idle()
	return MobileIntent.idle(snapshot.selected_shot_slot)
