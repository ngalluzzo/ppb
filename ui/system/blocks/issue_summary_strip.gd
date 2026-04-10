@tool
class_name IssueSummaryStrip
extends "res://ui/system/patterns/summary_strip.gd"

func set_counts(errors: int, warnings: int, info: int) -> void:
	set_parts([
		"Errors: %d" % errors,
		"Warnings: %d" % warnings,
		"Info: %d" % info,
	])

