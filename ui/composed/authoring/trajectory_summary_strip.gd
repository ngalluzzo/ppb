@tool
class_name TrajectorySummaryStrip
extends "res://ui/system/patterns/metric_triplet.gd"

const MetricViewScript = preload("res://ui/contracts/metric_view.gd")

func set_summary(summary: Dictionary) -> void:
	set_metrics([
		MetricViewScript.new("Projectiles", str(summary.get("projectile_count", 0))),
		MetricViewScript.new("Airtime", str(summary.get("airtime", "-"))),
		MetricViewScript.new("Spread", str(summary.get("spread", "-"))),
	])

