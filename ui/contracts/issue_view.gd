class_name IssueView
extends RefCounted

var title: String = ""
var message: String = ""
var severity: StringName = &"info"
var code: StringName = StringName()

func _init(p_title: String = "", p_message: String = "", p_severity: StringName = &"info", p_code: StringName = StringName()) -> void:
	title = p_title
	message = p_message
	severity = p_severity
	code = p_code
