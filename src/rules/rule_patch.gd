class_name RulePatch
extends RefCounted

enum Operation {
	SET,
	ADD,
	MULTIPLY,
	ENABLE,
	DISABLE,
}

var path: String
var operation: Operation
var value: Variant


func _init(rule_path: String = "", patch_operation: Operation = Operation.SET, patch_value: Variant = null) -> void:
	path = rule_path
	operation = patch_operation
	value = patch_value
