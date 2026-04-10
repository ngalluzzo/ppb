@tool
class_name ResourcePickerRow
extends VBoxContainer

const InspectorFieldRowScript = preload("res://ui/system/blocks/inspector_field_row.gd")
const ResourcePathRowScript = preload("res://ui/system/blocks/resource_path_row.gd")
const AppUIScript = preload("res://ui/system/theme/app_ui.gd")
const AppTextFieldScript = preload("res://ui/system/primitives/app_text_field.gd")

signal resource_changed(resource: Resource)

@export var scope: int = AppUIScript.Scope.EDITOR

var _field_row: Control
var _picker: EditorResourcePicker
var _picker_fallback: LineEdit
var _path_row: Control
var _label_text: String = ""
var _base_type: String = ""
var _pending_resource: Resource
var _pending_path_text: String = ""

func _ready() -> void:
	_ensure_ui()

func _ensure_ui() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	if _field_row == null:
		_field_row = InspectorFieldRowScript.new()
		_field_row.scope = scope
		add_child(_field_row)
		if Engine.is_editor_hint():
			_picker = EditorResourcePicker.new()
			_picker.size_flags_horizontal = SIZE_EXPAND_FILL
			_picker.resource_changed.connect(_on_resource_changed)
			_field_row.get_content_root().add_child(_picker)
		else:
			_picker_fallback = AppTextFieldScript.new()
			_picker_fallback.scope = scope
			_picker_fallback.size_flags_horizontal = SIZE_EXPAND_FILL
			_picker_fallback.editable = false
			_picker_fallback.placeholder_text = "Editor-only resource picker (%s)" % _base_type
			_field_row.get_content_root().add_child(_picker_fallback)
		_path_row = ResourcePathRowScript.new()
		_path_row.scope = scope
		_path_row.set_label_text("Path")
		add_child(_path_row)
	_field_row.set_label_text(_label_text)
	if _picker != null:
		_picker.base_type = _base_type
		_picker.edited_resource = _pending_resource
	if _picker_fallback != null:
		_picker_fallback.placeholder_text = "Editor-only resource picker (%s)" % _base_type
		_picker_fallback.text = _describe_resource(_pending_resource)
	if _pending_path_text != "":
		_path_row.set_value_text(_pending_path_text)
		_path_row.visible = true
	_update_path()

func set_label_text(text: String) -> void:
	_label_text = text
	_ensure_ui()

func set_base_type(base_type: String) -> void:
	_base_type = base_type
	_ensure_ui()

func set_edited_resource(resource: Resource) -> void:
	_pending_resource = resource
	_ensure_ui()
	if _picker != null:
		_picker.edited_resource = resource
	if _picker_fallback != null:
		_picker_fallback.text = _describe_resource(resource)
	_update_path()

func get_edited_resource() -> Resource:
	_ensure_ui()
	return _picker.edited_resource if _picker != null else _pending_resource

func get_picker() -> EditorResourcePicker:
	_ensure_ui()
	return _picker

func set_path_text(text: String) -> void:
	_pending_path_text = text
	_ensure_ui()
	if _path_row != null:
		_path_row.set_value_text(text)
		_path_row.visible = text != ""

func _on_resource_changed(resource: Resource) -> void:
	_update_path()
	resource_changed.emit(resource)

func _update_path() -> void:
	if _path_row == null:
		return
	var resource := _picker.edited_resource if _picker != null else _pending_resource
	var path := resource.resource_path if resource != null else ""
	_path_row.set_value_text(path)
	_path_row.visible = path != ""

func _describe_resource(resource: Resource) -> String:
	if resource == null:
		return ""
	if resource.resource_path != "":
		return resource.resource_path
	if resource.resource_name != "":
		return resource.resource_name
	return resource.get_class()
