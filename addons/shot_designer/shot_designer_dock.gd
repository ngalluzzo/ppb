@tool
extends VBoxContainer

const ShotPreviewSessionScript = preload("res://addons/shot_designer/shot_preview_session.gd")
const ShotPreviewViewportScript = preload("res://addons/shot_designer/shot_preview_viewport.gd")

const ToolWorkspaceShellScript = preload("res://ui/system/blocks/tool_workspace_shell.gd")
const LinkedResourceSectionScript = preload("res://ui/system/blocks/linked_resource_section.gd")
const InspectorSectionScript = preload("res://ui/system/blocks/inspector_section.gd")
const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const ResourcePickerRowScript = preload("res://ui/system/blocks/resource_picker_row.gd")
const ResourcePathRowScript = preload("res://ui/system/blocks/resource_path_row.gd")
const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const ApplyResetReplayBarScript = preload("res://ui/system/blocks/apply_reset_replay_bar.gd")
const ExactPreviewPanelScript = preload("res://ui/composed/authoring/exact_preview_panel.gd")
const ResourceStackEditorScript = preload("res://ui/composed/authoring/resource_stack_editor.gd")
const NumericTuningRowScript = preload("res://ui/composed/authoring/numeric_tuning_row.gd")
const VectorTuningRowScript = preload("res://ui/composed/authoring/vector_tuning_row.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")

const AppSelectFieldScript = preload("res://ui/system/primitives/app_select_field.gd")
const AppSpinFieldScript = preload("res://ui/system/primitives/app_spin_field.gd")
const AppTextFieldScript = preload("res://ui/system/primitives/app_text_field.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var plugin: EditorPlugin

var _session: ShotPreviewSession = ShotPreviewSessionScript.new()
var _shell: Control
var _preview_viewport: Control
var _status_banner: Control
var _stack_editor: VBoxContainer
var _action_bar: Control
var _preview_panel: Control

var _mode_select: OptionButton
var _mobile_row: Control
var _direct_shot_row: Control
var _direct_mobile_row: Control
var _weather_row: Control
var _slot_row: Control
var _slot_select: OptionButton
var _angle_spin: SpinBox
var _power_spin: SpinBox
var _facing_select: OptionButton

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	size_flags_horizontal = SIZE_EXPAND_FILL
	_session.session_changed.connect(_on_session_changed)

	_shell = ToolWorkspaceShellScript.new()
	_shell.scope = AppUIScript.Scope.EDITOR
	add_child(_shell)
	_shell.set_title_text("Shot Designer")
	_shell.set_help_text("Pick a mobile or direct shot, stage linked resource edits in memory, and preview the exact runtime result in-place.")

	var toolbar = _shell.get_toolbar_root()
	var content = _shell.get_body_root()
	var status_root = _shell.get_status_root()

	var entry_section = LinkedResourceSectionScript.new()
	entry_section.scope = AppUIScript.Scope.EDITOR
	entry_section.set_title_text("Entry & Preview Context")
	entry_section.set_dirty_state(&"clean")
	toolbar.add_child(entry_section)
	_build_entry_controls(entry_section.get_content_root())

	_action_bar = ApplyResetReplayBarScript.new()
	_action_bar.scope = AppUIScript.Scope.EDITOR
	_action_bar.apply_pressed.connect(_on_apply_pressed)
	_action_bar.reset_pressed.connect(_on_reset_pressed)
	_action_bar.replay_pressed.connect(_on_replay_pressed)
	toolbar.add_child(_action_bar)

	_status_banner = StatusCalloutScript.new()
	_status_banner.scope = AppUIScript.Scope.EDITOR
	_status_banner.tone = "muted"
	status_root.add_child(_status_banner)

	_preview_panel = ExactPreviewPanelScript.new()
	_preview_panel.scope = AppUIScript.Scope.EDITOR
	_preview_panel.set_title_text("Exact Preview")
	_preview_panel.set_help_text("Uses the real preview runtime: BattleSystem, Cannon, ShotExecutionService, Projectile, and weather logic.")
	_preview_panel.replay_pressed.connect(_on_replay_pressed)
	content.add_child(_preview_panel)

	_preview_viewport = ShotPreviewViewportScript.new()
	_preview_viewport.size_flags_vertical = SIZE_EXPAND_FILL
	_preview_viewport.preview_updated.connect(_on_preview_updated)
	_preview_panel.get_preview_root().add_child(_preview_viewport)
	_preview_panel.set_legend([
		{"label": "Trajectories", "hint": "Captured from real runtime projectile positions."},
		{"label": "Endpoints", "hint": "Last live or impact endpoint marker for each projectile."},
	])

	var stack_section = LinkedResourceSectionScript.new()
	stack_section.scope = AppUIScript.Scope.EDITOR
	stack_section.set_title_text("Linked Shot Stack")
	stack_section.set_dirty_state(&"clean")
	content.add_child(stack_section)

	var stack_editor = ResourceStackEditorScript.new()
	stack_section.get_content_root().add_child(stack_editor)
	_stack_editor = stack_editor.get_stack_root()

	_sync_mode_visibility()
	_refresh_status()

func _build_entry_controls(container: VBoxContainer) -> void:
	var mode_row := InspectorFieldRowScript.new()
	mode_row.scope = AppUIScript.Scope.EDITOR
	mode_row.set_label_text("Entry Mode")
	container.add_child(mode_row)
	_mode_select = AppSelectFieldScript.new()
	_mode_select.scope = AppUIScript.Scope.EDITOR
	_mode_select.add_item("Mobile + Slot", 0)
	_mode_select.add_item("ShotPattern", 1)
	_mode_select.item_selected.connect(_on_mode_changed)
	mode_row.get_content_root().add_child(_mode_select)

	_mobile_row = ResourcePickerRowScript.new()
	_mobile_row.scope = AppUIScript.Scope.EDITOR
	_mobile_row.set_label_text("MobileDefinition")
	_mobile_row.set_base_type("MobileDefinition")
	_mobile_row.resource_changed.connect(_on_mobile_changed)
	container.add_child(_mobile_row)

	_slot_row = InspectorFieldRowScript.new()
	_slot_row.scope = AppUIScript.Scope.EDITOR
	_slot_row.set_label_text("Shot Slot")
	container.add_child(_slot_row)
	_slot_select = AppSelectFieldScript.new()
	_slot_select.scope = AppUIScript.Scope.EDITOR
	_slot_select.add_item("shot_1", 0)
	_slot_select.add_item("shot_2", 1)
	_slot_select.add_item("shot_ss", 2)
	_slot_select.item_selected.connect(_on_slot_selected)
	_slot_row.get_content_root().add_child(_slot_select)

	_direct_shot_row = ResourcePickerRowScript.new()
	_direct_shot_row.scope = AppUIScript.Scope.EDITOR
	_direct_shot_row.set_label_text("ShotPattern")
	_direct_shot_row.set_base_type("ShotPattern")
	_direct_shot_row.resource_changed.connect(_on_direct_shot_changed)
	container.add_child(_direct_shot_row)

	_direct_mobile_row = ResourcePickerRowScript.new()
	_direct_mobile_row.scope = AppUIScript.Scope.EDITOR
	_direct_mobile_row.set_label_text("Direct Preview Mobile")
	_direct_mobile_row.set_base_type("MobileDefinition")
	_direct_mobile_row.resource_changed.connect(_on_direct_mobile_changed)
	container.add_child(_direct_mobile_row)

	_weather_row = ResourcePickerRowScript.new()
	_weather_row.scope = AppUIScript.Scope.EDITOR
	_weather_row.set_label_text("Weather Config")
	_weather_row.set_base_type("MatchWeatherConfig")
	_weather_row.resource_changed.connect(_on_weather_changed)
	container.add_child(_weather_row)

	var angle_row := InspectorFieldRowScript.new()
	angle_row.scope = AppUIScript.Scope.EDITOR
	angle_row.set_label_text("Preview Angle")
	container.add_child(angle_row)
	_angle_spin = AppSpinFieldScript.new()
	_angle_spin.scope = AppUIScript.Scope.EDITOR
	_angle_spin.min_value = -180.0
	_angle_spin.max_value = 180.0
	_angle_spin.step = 0.5
	_angle_spin.value = 45.0
	_angle_spin.value_changed.connect(_on_preview_angle_changed)
	angle_row.get_content_root().add_child(_angle_spin)

	var power_row := InspectorFieldRowScript.new()
	power_row.scope = AppUIScript.Scope.EDITOR
	power_row.set_label_text("Preview Power")
	container.add_child(power_row)
	_power_spin = AppSpinFieldScript.new()
	_power_spin.scope = AppUIScript.Scope.EDITOR
	_power_spin.min_value = 0.0
	_power_spin.max_value = 200.0
	_power_spin.step = 1.0
	_power_spin.value = 50.0
	_power_spin.value_changed.connect(_on_preview_power_changed)
	power_row.get_content_root().add_child(_power_spin)

	var facing_row := InspectorFieldRowScript.new()
	facing_row.scope = AppUIScript.Scope.EDITOR
	facing_row.set_label_text("Facing")
	container.add_child(facing_row)
	_facing_select = AppSelectFieldScript.new()
	_facing_select.scope = AppUIScript.Scope.EDITOR
	_facing_select.add_item("Right", 0)
	_facing_select.add_item("Left", 1)
	_facing_select.item_selected.connect(_on_facing_selected)
	facing_row.get_content_root().add_child(_facing_select)

func _on_mode_changed(index: int) -> void:
	_sync_mode_visibility()
	if index == 0:
		_on_mobile_changed(_mobile_row.get_edited_resource())
	else:
		_on_direct_shot_changed(_direct_shot_row.get_edited_resource())

func _sync_mode_visibility() -> void:
	var mobile_mode := _mode_select.get_selected_id() == 0
	_mobile_row.visible = mobile_mode
	_slot_row.visible = mobile_mode
	_direct_shot_row.visible = not mobile_mode
	_direct_mobile_row.visible = not mobile_mode

func _on_mobile_changed(resource: Resource) -> void:
	if resource == null:
		_session.clear()
		return
	_session.open_mobile_slot(resource as MobileDefinition, _get_selected_slot())
	_apply_preview_controls_to_session()

func _on_slot_selected(_index: int) -> void:
	if _mode_select.get_selected_id() == 0:
		_on_mobile_changed(_mobile_row.get_edited_resource())
	else:
		_session.mark_dirty(&"preview")
		_preview_viewport.request_refresh()

func _on_direct_shot_changed(resource: Resource) -> void:
	if resource == null:
		_session.clear()
		return
	_session.open_shot_pattern(resource as ShotPattern, _direct_mobile_row.get_edited_resource() as MobileDefinition)
	_apply_preview_controls_to_session()

func _on_direct_mobile_changed(resource: Resource) -> void:
	if _mode_select.get_selected_id() != 1:
		return
	_session.set_direct_preview_mobile_definition(resource as MobileDefinition)
	_apply_preview_controls_to_session()

func _on_weather_changed(resource: Resource) -> void:
	if _session.overrides == null:
		return
	_session.overrides.weather_config = resource as MatchWeatherConfig
	_session.mark_dirty(&"preview")
	_preview_viewport.request_refresh()
	_refresh_status()

func _on_preview_angle_changed(value: float) -> void:
	if _session.overrides == null:
		return
	_session.overrides.angle = value
	_session.mark_dirty(&"preview")
	_preview_viewport.request_refresh()

func _on_preview_power_changed(value: float) -> void:
	if _session.overrides == null:
		return
	_session.overrides.power = value
	_session.mark_dirty(&"preview")
	_preview_viewport.request_refresh()

func _on_facing_selected(index: int) -> void:
	if _session.overrides == null:
		return
	_session.overrides.facing_direction = 1 if index == 0 else -1
	_session.mark_dirty(&"preview")
	_preview_viewport.request_refresh()

func _on_reset_pressed() -> void:
	_session.reset()
	_apply_preview_controls_to_session(false)

func _on_apply_pressed() -> void:
	var result := _session.apply_changes()
	if result.get("ok", false):
		if plugin != null and plugin.get_editor_interface() != null:
			var filesystem := plugin.get_editor_interface().get_resource_filesystem()
			if filesystem != null:
				filesystem.scan()
	_refresh_status(str(result.get("message", "")))
	_preview_viewport.set_session(_session)

func _on_replay_pressed() -> void:
	_preview_viewport.request_refresh()

func _on_session_changed() -> void:
	_rebuild_stack_editor()
	_refresh_preview_controls()
	_preview_viewport.set_session(_session)
	_refresh_status()

func _on_preview_updated(snapshot: Dictionary) -> void:
	_preview_panel.set_summary({
		"projectile_count": int(snapshot.get("projectile_count", 0)),
		"airtime": "%.2fs" % float(snapshot.get("max_airtime_seconds", 0.0)),
		"spread": "%.1f" % float(snapshot.get("spread_width", 0.0)),
	})
	_refresh_status("", snapshot)

func _apply_preview_controls_to_session(refresh_preview: bool = true) -> void:
	if _session.overrides == null:
		return
	_session.overrides.weather_config = _weather_row.get_edited_resource() as MatchWeatherConfig
	_session.overrides.angle = _angle_spin.value
	_session.overrides.power = _power_spin.value
	_session.overrides.facing_direction = 1 if _facing_select.get_selected_id() == 0 else -1
	if refresh_preview:
		_preview_viewport.set_session(_session)
	_refresh_preview_controls()

func _refresh_preview_controls() -> void:
	if _session.overrides == null:
		return
	_angle_spin.value = _session.overrides.angle
	_power_spin.value = _session.overrides.power
	_facing_select.select(0 if _session.overrides.facing_direction >= 0 else 1)
	_weather_row.set_edited_resource(_session.overrides.weather_config)

func _refresh_status(message: String = "", preview_snapshot: Dictionary = {}) -> void:
	var summary := _session.get_summary_snapshot()
	var dirty_text := "Dirty" if bool(summary.get("dirty", false)) else "Clean"
	var preview_text := ""
	if not preview_snapshot.is_empty():
		preview_text = " | Preview: %s" % _preview_viewport._format_summary(preview_snapshot)
	_status_banner.tone = "warning" if bool(summary.get("dirty", false)) else "muted"
	_status_banner.set_text_value("%s [%s]%s%s" % [
		str(summary.get("display_name", "No shot selected")),
		dirty_text,
		": %s" % message if message != "" else "",
		preview_text
	])
	_action_bar.set_dirty_state(&"dirty" if bool(summary.get("dirty", false)) else &"clean")

func _rebuild_stack_editor() -> void:
	for child in _stack_editor.get_children():
		child.queue_free()
	if not _session.is_ready():
		return
	var paths := _session.get_path_map()
	var overrides := _session.overrides
	var phase_entry_paths: Array = paths.get("phase_entries", [])

	var shot_section = _make_section("ShotPattern", str(paths.get("shot_pattern", "")))
	shot_section.get_content_root().add_child(_make_numeric_row("unit_count", overrides.shot_pattern.unit_count, 1.0, func(value): overrides.shot_pattern.unit_count = int(value); _session.mark_dirty(&"shot_pattern"); _preview_viewport.request_refresh()))
	shot_section.get_content_root().add_child(_make_numeric_row("stagger_delay", overrides.shot_pattern.stagger_delay, 0.01, func(value): overrides.shot_pattern.stagger_delay = value; _session.mark_dirty(&"shot_pattern"); _preview_viewport.request_refresh()))
	shot_section.get_content_root().add_child(_make_numeric_row("unit_spacing", overrides.shot_pattern.unit_spacing, 1.0, func(value): overrides.shot_pattern.unit_spacing = value; _session.mark_dirty(&"shot_pattern"); _preview_viewport.request_refresh()))
	shot_section.get_content_root().add_child(_make_numeric_row("max_range", overrides.shot_pattern.max_range, 1.0, func(value): overrides.shot_pattern.max_range = value; _session.mark_dirty(&"shot_pattern"); _preview_viewport.request_refresh()))
	_stack_editor.add_child(shot_section)

	var arc_section = _make_section("ArcConfig", str(paths.get("arc_config", "")))
	arc_section.get_content_root().add_child(_make_numeric_row("gravity", overrides.arc_config.gravity, 1.0, func(value): overrides.arc_config.gravity = value; _session.mark_dirty(&"arc_config"); _preview_viewport.request_refresh()))
	arc_section.get_content_root().add_child(_make_numeric_row("wind_factor", overrides.arc_config.wind_factor, 0.05, func(value): overrides.arc_config.wind_factor = value; _session.mark_dirty(&"arc_config"); _preview_viewport.request_refresh()))
	arc_section.get_content_root().add_child(_make_numeric_row("power_scale", overrides.arc_config.power_scale, 0.1, func(value): overrides.arc_config.power_scale = value; _session.mark_dirty(&"arc_config"); _preview_viewport.request_refresh()))
	_stack_editor.add_child(arc_section)

	var projectile_section = _make_section("ProjectileDefinition", str(paths.get("projectile_definition", "")))
	projectile_section.get_content_root().add_child(_make_text_row("name", overrides.projectile_definition.name, func(value): overrides.projectile_definition.name = value; _session.mark_dirty(&"projectile_definition"); _preview_viewport.request_refresh()))
	projectile_section.get_content_root().add_child(_make_numeric_row("collision_radius", overrides.projectile_definition.collision_radius, 0.5, func(value): overrides.projectile_definition.collision_radius = value; _session.mark_dirty(&"projectile_definition"); _preview_viewport.request_refresh()))
	projectile_section.get_content_root().add_child(_make_vector2i_row("frame_size", overrides.projectile_definition.frame_size, func(value): overrides.projectile_definition.frame_size = value; _session.mark_dirty(&"projectile_definition")))
	projectile_section.get_content_root().add_child(_make_numeric_row("frame_count", overrides.projectile_definition.frame_count, 1.0, func(value): overrides.projectile_definition.frame_count = int(value); _session.mark_dirty(&"projectile_definition")))
	projectile_section.get_content_root().add_child(_make_numeric_row("animation_speed", overrides.projectile_definition.animation_speed, 0.1, func(value): overrides.projectile_definition.animation_speed = value; _session.mark_dirty(&"projectile_definition")))
	projectile_section.get_content_root().add_child(_make_path_row("sprite_sheet", overrides.projectile_definition.sprite_sheet.resource_path if overrides.projectile_definition.sprite_sheet != null else ""))
	_stack_editor.add_child(projectile_section)

	var impact_section = _make_section("ImpactDefinition", str(paths.get("impact_definition", "")))
	impact_section.get_content_root().add_child(_make_numeric_row("damage", overrides.impact_definition.damage, 1.0, func(value): overrides.impact_definition.damage = value; _session.mark_dirty(&"impact_definition"); _preview_viewport.request_refresh()))
	impact_section.get_content_root().add_child(_make_numeric_row("radius", overrides.impact_definition.radius, 0.5, func(value): overrides.impact_definition.radius = value; _session.mark_dirty(&"impact_definition"); _preview_viewport.request_refresh()))
	impact_section.get_content_root().add_child(_make_numeric_row("drill_power", overrides.impact_definition.drill_power, 0.5, func(value): overrides.impact_definition.drill_power = value; _session.mark_dirty(&"impact_definition"); _preview_viewport.request_refresh()))
	_stack_editor.add_child(impact_section)

	var phase_section = _make_section("PhaseLine", str(paths.get("phase_line", "")))
	for index in overrides.phase_entries.size():
		var path := ""
		if index < phase_entry_paths.size():
			path = phase_entry_paths[index]
		phase_section.get_content_root().add_child(_make_path_row("phase_%d" % index, path))
		phase_section.get_content_root().add_child(_make_path_row("behavior_%d" % index, overrides.phase_entries[index].behavior.resource_path if overrides.phase_entries[index] != null and overrides.phase_entries[index].behavior != null else ""))
		phase_section.get_content_root().add_child(_make_numeric_row("phase_%d_duration" % index, overrides.phase_entries[index].duration, 0.05, func(value, phase_index := index): overrides.phase_entries[phase_index].duration = value; overrides.phase_line.phases = overrides.phase_entries.duplicate(); _session.mark_dirty(&"phase_entries"); _preview_viewport.request_refresh()))
	_stack_editor.add_child(phase_section)

func _make_section(title: String, path: String):
	var section := LinkedResourceSectionScript.new()
	section.scope = AppUIScript.Scope.EDITOR
	section.set_title_text(title)
	section.set_path_text(path)
	section.set_dirty_state(&"dirty" if bool(_session.get_dirty_state().get(title.to_snake_case(), false)) else &"clean")
	return section

func _make_numeric_row(label_text: String, value: float, step: float, callback: Callable):
	var row := NumericTuningRowScript.new()
	row.scope = AppUIScript.Scope.EDITOR
	row.set_label_text(label_text)
	var spin := row.get_spin_box()
	spin.min_value = -10000.0
	spin.max_value = 10000.0
	spin.step = step
	spin.value = value
	spin.value_changed.connect(callback)
	return row

func _make_text_row(label_text: String, value: String, callback: Callable):
	var row := InspectorFieldRowScript.new()
	row.scope = AppUIScript.Scope.EDITOR
	row.set_label_text(label_text)
	var edit := AppTextFieldScript.new()
	edit.scope = AppUIScript.Scope.EDITOR
	edit.text = value
	edit.size_flags_horizontal = SIZE_EXPAND_FILL
	edit.text_changed.connect(callback)
	row.get_content_root().add_child(edit)
	return row

func _make_vector2i_row(label_text: String, value: Vector2i, callback: Callable):
	var row := VectorTuningRowScript.new()
	row.scope = AppUIScript.Scope.EDITOR
	row.set_label_text(label_text)
	var x_spin := row.get_x_spin_box()
	x_spin.min_value = 1
	x_spin.max_value = 2048
	x_spin.step = 1
	x_spin.value = value.x
	var y_spin := row.get_y_spin_box()
	y_spin.min_value = 1
	y_spin.max_value = 2048
	y_spin.step = 1
	y_spin.value = value.y
	x_spin.value_changed.connect(func(_value): callback.call(Vector2i(int(x_spin.value), int(y_spin.value))))
	y_spin.value_changed.connect(func(_value): callback.call(Vector2i(int(x_spin.value), int(y_spin.value))))
	return row

func _make_path_row(label_text: String, path: String):
	var row := ResourcePathRowScript.new()
	row.scope = AppUIScript.Scope.EDITOR
	row.set_label_text(label_text)
	row.set_value_text(path)
	return row

func _get_selected_slot() -> StringName:
	match _slot_select.get_selected_id():
		0:
			return &"shot_1"
		1:
			return &"shot_2"
		2:
			return &"shot_ss"
		_:
			return &"shot_1"
