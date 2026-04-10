class_name ResourceValidation
extends RefCounted

static func matches_script(value, expected_script: Script) -> bool:
	if value == null or expected_script == null or not (value is Object):
		return false
	var script = value.get_script()
	while script != null:
		if script == expected_script:
			return true
		script = script.get_base_script()
	return false

static func require_resource(value, expected_script: Script, expected_name: String, label: String):
	if value == null:
		return null
	if matches_script(value, expected_script):
		return value
	push_error("%s must be a %s." % [label, expected_name])
	return null

static func filter_resources(values: Array, expected_script: Script, expected_name: String, label: String) -> Array[Resource]:
	var filtered: Array[Resource] = []
	for index in values.size():
		var value = values[index]
		if value == null:
			continue
		if matches_script(value, expected_script):
			filtered.append(value)
			continue
		push_error("%s[%d] must be a %s." % [label, index, expected_name])
	return filtered

