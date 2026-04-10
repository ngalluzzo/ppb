@tool
class_name ShotPreviewSession
extends RefCounted

const ShotPreviewResourceBundleScript = preload("res://addons/shot_designer/shot_preview_resource_bundle.gd")
const ShotPreviewOverridesScript = preload("res://addons/shot_designer/shot_preview_overrides.gd")

signal session_changed()

var bundle: ShotPreviewResourceBundle
var overrides: ShotPreviewOverrides
var dirty_layers: Dictionary = {}
var status_text: String = "No shot selected."

func open_mobile_slot(mobile_def: MobileDefinition, slot: StringName) -> void:
	bundle = ShotPreviewResourceBundleScript.from_mobile_slot(mobile_def, slot)
	_reload_from_bundle()

func open_shot_pattern(shot_pattern: ShotPattern, preview_mobile_def: MobileDefinition = null) -> void:
	bundle = ShotPreviewResourceBundleScript.from_shot_pattern(shot_pattern, preview_mobile_def)
	_reload_from_bundle()

func clear() -> void:
	bundle = null
	overrides = null
	dirty_layers = {}
	status_text = "No shot selected."
	session_changed.emit()

func set_direct_preview_mobile_definition(preview_mobile_def: MobileDefinition) -> void:
	if bundle == null or bundle.entry_mode != ShotPreviewResourceBundle.EntryMode.SHOT_PATTERN:
		return
	open_shot_pattern(bundle.shot_pattern, preview_mobile_def)

func is_ready() -> bool:
	return bundle != null and bundle.is_valid() and overrides != null and overrides.shot_pattern != null

func uses_mobile_actor() -> bool:
	return bundle != null and bundle.uses_mobile_actor()

func get_preview_mobile_definition() -> MobileDefinition:
	return overrides.preview_mobile_definition if overrides != null else null

func get_preview_cannon_definition() -> CannonDefinition:
	return bundle.get_preview_cannon_definition() if bundle != null else null

func get_preview_slot() -> StringName:
	return bundle.shot_slot if bundle != null else &"shot_1"

func get_path_map() -> Dictionary:
	return bundle.get_path_map() if bundle != null else {}

func get_dirty_state() -> Dictionary:
	return dirty_layers.duplicate(true)

func is_dirty() -> bool:
	for key in dirty_layers.keys():
		if dirty_layers[key]:
			return true
	return false

func mark_dirty(layer: StringName) -> void:
	dirty_layers[String(layer)] = true
	session_changed.emit()

func reset() -> void:
	_reload_from_bundle()

func apply_changes() -> Dictionary:
	if not is_ready():
		return {"ok": false, "message": "No valid shot session to apply."}
	var paths := get_path_map()
	var impact_path := str(paths.get("impact_definition", ""))
	var projectile_path := str(paths.get("projectile_definition", ""))
	var arc_path := str(paths.get("arc_config", ""))
	var phase_line_path := str(paths.get("phase_line", ""))
	var shot_pattern_path := str(paths.get("shot_pattern", ""))
	var phase_entry_paths: Array = paths.get("phase_entries", [])
	if not _ensure_save_path(impact_path, "ImpactDefinition"):
		return {"ok": false, "message": "ImpactDefinition resource path is missing."}
	if not _ensure_save_path(projectile_path, "ProjectileDefinition"):
		return {"ok": false, "message": "ProjectileDefinition resource path is missing."}
	if not _ensure_save_path(arc_path, "ArcConfig"):
		return {"ok": false, "message": "ArcConfig resource path is missing."}
	if not _ensure_save_path(phase_line_path, "PhaseLine"):
		return {"ok": false, "message": "PhaseLine resource path is missing."}
	if not _ensure_save_path(shot_pattern_path, "ShotPattern"):
		return {"ok": false, "message": "ShotPattern resource path is missing."}
	var rollback_buffers := _capture_rollback_buffers([
		impact_path,
		projectile_path,
		arc_path,
		phase_line_path,
		shot_pattern_path
	] + phase_entry_paths)
	var saved_paths: Array[String] = []

	if not _save_with_rollback(overrides.impact_definition, impact_path, "ImpactDefinition", saved_paths, rollback_buffers):
		return _rollback_failure_result("Failed to save ImpactDefinition.", saved_paths, rollback_buffers)

	overrides.projectile_definition.impact_def = overrides.impact_definition
	if not _save_with_rollback(overrides.projectile_definition, projectile_path, "ProjectileDefinition", saved_paths, rollback_buffers):
		return _rollback_failure_result("Failed to save ProjectileDefinition.", saved_paths, rollback_buffers)

	if not _save_with_rollback(overrides.arc_config, arc_path, "ArcConfig", saved_paths, rollback_buffers):
		return _rollback_failure_result("Failed to save ArcConfig.", saved_paths, rollback_buffers)

	for index in overrides.phase_entries.size():
		var path := ""
		if index < phase_entry_paths.size():
			path = phase_entry_paths[index]
		if path == "":
			return _rollback_failure_result("PhaseEntry %d resource path is missing." % index, saved_paths, rollback_buffers)
		if not _save_with_rollback(overrides.phase_entries[index], path, "PhaseEntry %d" % index, saved_paths, rollback_buffers):
			return _rollback_failure_result("Failed to save PhaseEntry %d." % index, saved_paths, rollback_buffers)

	overrides.phase_line.phases = overrides.phase_entries.duplicate()
	if not _save_with_rollback(overrides.phase_line, phase_line_path, "PhaseLine", saved_paths, rollback_buffers):
		return _rollback_failure_result("Failed to save PhaseLine.", saved_paths, rollback_buffers)

	overrides.shot_pattern.projectile_def = overrides.projectile_definition
	overrides.shot_pattern.arc_config = overrides.arc_config
	overrides.shot_pattern.phase_line = overrides.phase_line
	if not _save_with_rollback(overrides.shot_pattern, shot_pattern_path, "ShotPattern", saved_paths, rollback_buffers):
		return _rollback_failure_result("Failed to save ShotPattern.", saved_paths, rollback_buffers)

	_reload_from_sources()
	return {"ok": true, "message": "Applied staged changes to linked resources."}

func get_summary_snapshot() -> Dictionary:
	return {
		"ready": is_ready(),
		"entry_mode": bundle.entry_mode if bundle != null else -1,
		"display_name": bundle.get_display_name() if bundle != null else "No shot selected",
		"dirty": is_dirty(),
		"dirty_layers": get_dirty_state(),
		"status": status_text,
	}

func _reload_from_bundle() -> void:
	overrides = ShotPreviewOverridesScript.from_bundle(bundle)
	dirty_layers = {
		"shot_pattern": false,
		"arc_config": false,
		"projectile_definition": false,
		"impact_definition": false,
		"phase_line": false,
		"phase_entries": false,
		"preview": false,
	}
	status_text = bundle.get_display_name() if bundle != null and bundle.is_valid() else "No valid shot selected."
	session_changed.emit()

func _reload_from_sources() -> void:
	if bundle == null:
		return
	var paths := get_path_map()
	var mobile_path := str(paths.get("mobile_definition", ""))
	var shot_pattern_path := str(paths.get("shot_pattern", ""))
	if bundle.mobile_definition != null and mobile_path != "":
		bundle.mobile_definition = ResourceLoader.load(mobile_path, "", ResourceLoader.CACHE_MODE_REPLACE) as MobileDefinition
	if shot_pattern_path != "":
		var refreshed_pattern := ResourceLoader.load(shot_pattern_path, "", ResourceLoader.CACHE_MODE_REPLACE) as ShotPattern
		if bundle.entry_mode == ShotPreviewResourceBundle.EntryMode.MOBILE_SLOT and bundle.mobile_definition != null:
			open_mobile_slot(bundle.mobile_definition, bundle.shot_slot)
			return
		open_shot_pattern(refreshed_pattern, bundle.preview_mobile_definition)

func _ensure_save_path(path: String, label: String) -> bool:
	if path == "":
		push_error("ShotPreviewSession: %s has no resource_path." % label)
		return false
	return true

func _capture_rollback_buffers(paths: Array) -> Dictionary:
	var buffers := {}
	for raw_path in paths:
		var path := str(raw_path)
		if path == "" or buffers.has(path):
			continue
		buffers[path] = FileAccess.get_file_as_bytes(path)
	return buffers

func _save_with_rollback(resource: Resource, path: String, _label: String, saved_paths: Array[String], _rollback_buffers: Dictionary) -> bool:
	if ResourceSaver.save(resource, path) != OK:
		return false
	if not saved_paths.has(path):
		saved_paths.append(path)
	return true

func _rollback_failure_result(message: String, saved_paths: Array[String], rollback_buffers: Dictionary) -> Dictionary:
	var rollback_error := _restore_saved_paths(saved_paths, rollback_buffers)
	if rollback_error != "":
		return {"ok": false, "message": "%s Rollback failed: %s" % [message, rollback_error]}
	return {"ok": false, "message": "%s Changes were rolled back." % message}

func _restore_saved_paths(saved_paths: Array[String], rollback_buffers: Dictionary) -> String:
	for index in range(saved_paths.size() - 1, -1, -1):
		var path := saved_paths[index]
		if not rollback_buffers.has(path):
			continue
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			return "Could not reopen %s." % path
		file.store_buffer(rollback_buffers[path])
	return ""
