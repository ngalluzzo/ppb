@tool
class_name AmbientInfoFooter
extends "res://ui/system/patterns/summary_strip.gd"

func set_info(version_text: String, hint_text: String, profile_text: String = "") -> void:
	var parts := [version_text, hint_text]
	if profile_text != "":
		parts.append(profile_text)
	set_parts(parts)

