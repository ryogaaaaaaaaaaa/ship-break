class_name RuleService
extends Node

const RuleStateScript = preload("res://src/rules/rule_state.gd")
const RuleResolverScript = preload("res://src/rules/rule_resolver.gd")

var base_state: Variant
var patches: Array = []
var snapshot: Variant
var errors: Array[String] = []


func _ready() -> void:
	if snapshot == null:
		reset_to_default()


func reset_to_default() -> void:
	base_state = RuleStateScript.new()
	patches.clear()
	_resolve()


func set_base_state(next_base_state: Variant) -> void:
	base_state = next_base_state
	_resolve()


func add_patch(patch: Variant) -> void:
	patches.append(patch)
	_resolve()


func clear_patches() -> void:
	patches.clear()
	_resolve()


func get_snapshot() -> Variant:
	if snapshot == null:
		reset_to_default()
	return snapshot


func _resolve() -> void:
	if base_state == null:
		base_state = RuleStateScript.new()
	var result: Variant = RuleResolverScript.resolve(base_state, patches)
	snapshot = result.snapshot
	errors = result.errors
