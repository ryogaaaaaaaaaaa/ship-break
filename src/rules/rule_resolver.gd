class_name RuleResolver
extends RefCounted

const RulePatchScript = preload("res://src/rules/rule_patch.gd")
const RuleSnapshotScript = preload("res://src/rules/rule_snapshot.gd")
const RuleResolutionResultScript = preload("res://src/rules/rule_resolution_result.gd")


static func resolve(base_state: Variant, patches: Array = []) -> Variant:
	var values: Dictionary = base_state.to_dictionary()
	var errors: Array[String] = []
	for patch in patches:
		var error_message: String = _apply_patch(values, patch)
		if not error_message.is_empty():
			errors.append(error_message)
	return RuleResolutionResultScript.new(RuleSnapshotScript.new(values), errors)


static func _apply_patch(values: Dictionary, patch: Variant) -> String:
	var path_parts: PackedStringArray = patch.path.split(".")
	if path_parts.size() == 0:
		return "Rule patch path is empty."

	var parent: Dictionary = values
	for index in range(path_parts.size() - 1):
		var part: String = path_parts[index]
		if not parent.has(part) or not parent[part] is Dictionary:
			return "Invalid rule path: %s" % patch.path
		parent = parent[part]

	var leaf_key: String = path_parts[path_parts.size() - 1]
	if not parent.has(leaf_key):
		return "Invalid rule path: %s" % patch.path

	var current_value: Variant = parent[leaf_key]
	match patch.operation:
		RulePatchScript.Operation.SET:
			parent[leaf_key] = patch.value
		RulePatchScript.Operation.ADD:
			if not _is_number(current_value) or not _is_number(patch.value):
				return "ADD requires numeric values: %s" % patch.path
			parent[leaf_key] = current_value + patch.value
		RulePatchScript.Operation.MULTIPLY:
			if not _is_number(current_value) or not _is_number(patch.value):
				return "MULTIPLY requires numeric values: %s" % patch.path
			parent[leaf_key] = current_value * patch.value
		RulePatchScript.Operation.ENABLE:
			parent[leaf_key] = true
		RulePatchScript.Operation.DISABLE:
			parent[leaf_key] = false
		_:
			return "Unknown rule patch operation: %s" % patch.operation
	return ""


static func _is_number(value: Variant) -> bool:
	return value is int or value is float
