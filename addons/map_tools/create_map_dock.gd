@tool
extends VBoxContainer

const MapSizePresetsScript = preload("res://map/map_size_presets.gd")

const MapCreationSectionScript = preload("res://ui/composed/authoring/map_creation_section.gd")
const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const StatusCalloutScript = preload("res://ui/composed/shared/status_callout.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const AppTextFieldScript = preload("res://ui/system/primitives/app_text_field.gd")
const AppSelectFieldScript = preload("res://ui/system/primitives/app_select_field.gd")
const AppButtonScript = preload("res://ui/system/primitives/app_button.gd")
const AppLabelScript = preload("res://ui/system/primitives/app_label.gd")

var plugin: EditorPlugin

var _name_edit: LineEdit
var _slug_edit: LineEdit
var _preset_select: OptionButton
var _status_banner: Control

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	AppUIScript.apply_theme(self, AppUIScript.Scope.EDITOR)

	var section = MapCreationSectionScript.new()
	section.scope = AppUIScript.Scope.EDITOR
	section.set_title_text("Create Standard Map")
	add_child(section)

	var help = AppLabelScript.new()
	help.scope = AppUIScript.Scope.EDITOR
	help.role = "body"
	help.text_role = "muted"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = "Creates a BattleMap scene and catalog with centered bounds, spawn lanes, and runtime camera guides."
	section.get_content_root().add_child(help)

	var name_row = InspectorFieldRowScript.new()
	name_row.scope = AppUIScript.Scope.EDITOR
	name_row.set_label_text("Display Name")
	section.get_content_root().add_child(name_row)
	_name_edit = AppTextFieldScript.new()
	_name_edit.scope = AppUIScript.Scope.EDITOR
	_name_edit.placeholder_text = "Grasslands"
	_name_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_name_edit.text_changed.connect(_on_name_changed)
	name_row.get_content_root().add_child(_name_edit)

	var slug_row = InspectorFieldRowScript.new()
	slug_row.scope = AppUIScript.Scope.EDITOR
	slug_row.set_label_text("Folder Slug")
	section.get_content_root().add_child(slug_row)
	_slug_edit = AppTextFieldScript.new()
	_slug_edit.scope = AppUIScript.Scope.EDITOR
	_slug_edit.placeholder_text = "grasslands"
	_slug_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	slug_row.get_content_root().add_child(_slug_edit)

	var preset_row = InspectorFieldRowScript.new()
	preset_row.scope = AppUIScript.Scope.EDITOR
	preset_row.set_label_text("Preset")
	section.get_content_root().add_child(preset_row)
	_preset_select = AppSelectFieldScript.new()
	_preset_select.scope = AppUIScript.Scope.EDITOR
	for i in MapSizePresetsScript.get_labels().size():
		_preset_select.add_item(MapSizePresetsScript.get_labels()[i], i)
	_preset_select.size_flags_horizontal = SIZE_EXPAND_FILL
	preset_row.get_content_root().add_child(_preset_select)

	var actions = HBoxContainer.new()
	actions.size_flags_horizontal = SIZE_EXPAND_FILL
	section.get_content_root().add_child(actions)

	var create_button = AppButtonScript.new()
	create_button.scope = AppUIScript.Scope.EDITOR
	create_button.variant = AppButtonScript.Variant.PRIMARY
	create_button.text = "Create Battle Map"
	create_button.pressed.connect(_on_create_pressed)
	actions.add_child(create_button)

	_status_banner = StatusCalloutScript.new()
	_status_banner.scope = AppUIScript.Scope.EDITOR
	_status_banner.tone = "muted"
	_status_banner.set_text_value("Choose a name and preset to scaffold a new map.")
	section.get_content_root().add_child(_status_banner)

func _on_name_changed(value: String) -> void:
	if _slug_edit.text.strip_edges() != "":
		return
	_slug_edit.text = _slugify(value)

func _on_create_pressed() -> void:
	if plugin == null:
		_set_status("Map Tools plugin is not ready yet.", "error")
		return

	var display_name := _name_edit.text.strip_edges()
	if display_name == "":
		_set_status("Enter a display name first.", "warning")
		return

	var slug := _slug_edit.text.strip_edges()
	if slug == "":
		slug = _slugify(display_name)
		_slug_edit.text = slug

	var result: Dictionary = plugin.create_standard_map(display_name, slug, _preset_select.get_selected_id())
	_set_status(str(result.get("message", "Map creation finished.")), "success" if result.get("ok", false) else "error")

func _set_status(text: String, tone: String) -> void:
	_status_banner.tone = tone
	_status_banner.set_text_value(text)

func _slugify(value: String) -> String:
	var lowered := value.to_lower().strip_edges()
	var slug := ""
	var last_was_dash := false
	for character in lowered:
		var code := character.unicode_at(0)
		var is_letter := code >= 97 and code <= 122
		var is_number := code >= 48 and code <= 57
		if is_letter or is_number:
			slug += character
			last_was_dash = false
		elif not last_was_dash:
			slug += "_"
			last_was_dash = true
	return slug.strip_edges().trim_suffix("_").trim_prefix("_")
