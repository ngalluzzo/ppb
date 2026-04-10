@tool
class_name ShotPreviewResourceBundle
extends RefCounted

const CannonDefaultResource = preload("res://weapon/cannon/cannon_default.tres")

enum EntryMode {
	MOBILE_SLOT,
	SHOT_PATTERN
}

var entry_mode: EntryMode = EntryMode.MOBILE_SLOT
var mobile_definition: MobileDefinition
var shot_slot: StringName = &"shot_1"
var shot_pattern: ShotPattern
var preview_mobile_definition: MobileDefinition
var preview_cannon_definition: CannonDefinition
var arc_config: ArcConfig
var projectile_definition: ProjectileDefinition
var impact_definition: ImpactDefinition
var phase_line: PhaseLine
var phase_entries: Array[PhaseEntry] = []

static func from_mobile_slot(mobile_def: MobileDefinition, slot: StringName) -> ShotPreviewResourceBundle:
	var bundle := ShotPreviewResourceBundle.new()
	bundle.entry_mode = EntryMode.MOBILE_SLOT
	bundle.mobile_definition = mobile_def
	bundle.preview_mobile_definition = mobile_def
	bundle.shot_slot = slot
	bundle.shot_pattern = _resolve_shot_pattern(mobile_def, slot)
	bundle._resolve_stack()
	return bundle

static func from_shot_pattern(shot_pattern_resource: ShotPattern, preview_mobile_def: MobileDefinition = null) -> ShotPreviewResourceBundle:
	var bundle := ShotPreviewResourceBundle.new()
	bundle.entry_mode = EntryMode.SHOT_PATTERN
	bundle.shot_pattern = shot_pattern_resource
	bundle.preview_mobile_definition = preview_mobile_def
	bundle.shot_slot = &"shot_1"
	bundle._resolve_stack()
	return bundle

func is_valid() -> bool:
	return shot_pattern != null and arc_config != null and projectile_definition != null and impact_definition != null

func uses_mobile_actor() -> bool:
	return preview_mobile_definition != null

func get_preview_cannon_definition() -> CannonDefinition:
	if preview_mobile_definition != null and preview_mobile_definition.cannon_def != null:
		return preview_mobile_definition.cannon_def
	return preview_cannon_definition

func get_display_name() -> String:
	if entry_mode == EntryMode.MOBILE_SLOT and mobile_definition != null:
		return "%s %s" % [mobile_definition.name, String(shot_slot)]
	if shot_pattern != null and shot_pattern.resource_path != "":
		return shot_pattern.resource_path.get_file()
	return "Shot Preview"

func get_path_map() -> Dictionary:
	return {
		"mobile_definition": mobile_definition.resource_path if mobile_definition != null else "",
		"shot_pattern": shot_pattern.resource_path if shot_pattern != null else "",
		"arc_config": arc_config.resource_path if arc_config != null else "",
		"projectile_definition": projectile_definition.resource_path if projectile_definition != null else "",
		"impact_definition": impact_definition.resource_path if impact_definition != null else "",
		"phase_line": phase_line.resource_path if phase_line != null else "",
		"phase_entries": phase_entries.map(func(entry: PhaseEntry): return entry.resource_path if entry != null else ""),
		"preview_mobile_definition": preview_mobile_definition.resource_path if preview_mobile_definition != null else "",
		"preview_cannon_definition": get_preview_cannon_definition().resource_path if get_preview_cannon_definition() != null else ""
	}

func _resolve_stack() -> void:
	arc_config = shot_pattern.arc_config if shot_pattern != null else null
	projectile_definition = shot_pattern.projectile_def if shot_pattern != null else null
	impact_definition = projectile_definition.impact_def if projectile_definition != null else null
	phase_line = shot_pattern.phase_line if shot_pattern != null else null
	phase_entries = phase_line.phases.duplicate() if phase_line != null else []
	preview_cannon_definition = get_preview_cannon_definition()
	if preview_cannon_definition == null:
		preview_cannon_definition = CannonDefaultResource

static func _resolve_shot_pattern(mobile_def: MobileDefinition, slot: StringName) -> ShotPattern:
	if mobile_def == null:
		return null
	match slot:
		&"shot_1":
			return mobile_def.shot_1
		&"shot_2":
			return mobile_def.shot_2
		&"shot_ss":
			return mobile_def.shot_ss
		_:
			return mobile_def.shot_1
