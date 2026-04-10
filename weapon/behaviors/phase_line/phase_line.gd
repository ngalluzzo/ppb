class_name PhaseLine
extends Resource

@export var phases: Array[PhaseEntry] = []

func get_behavior_at(progress: float) -> OffsetBehavior:
	var accumulated: float = 0.0
	var last_entry: PhaseEntry = null
	for entry in phases:
		last_entry = entry
		accumulated += entry.duration
		if progress <= accumulated:
			return entry.behavior
	if last_entry != null and last_entry.behavior != null and last_entry.behavior.continuous:
		return last_entry.behavior
	return null
