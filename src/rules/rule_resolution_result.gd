class_name RuleResolutionResult
extends RefCounted

var snapshot: Variant
var errors: Array[String]


func _init(result_snapshot: Variant, result_errors: Array[String] = []) -> void:
	snapshot = result_snapshot
	errors = result_errors.duplicate()


func is_ok() -> bool:
	return errors.is_empty()
