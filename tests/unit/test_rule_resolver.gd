extends RefCounted

const RuleStateScript := preload("res://src/rules/rule_state.gd")
const RulePatchScript := preload("res://src/rules/rule_patch.gd")
const RuleResolverScript := preload("res://src/rules/rule_resolver.gd")


func run(context) -> void:
	var base_state: Variant = RuleStateScript.new()
	var patches: Array = []
	patches.append(RulePatchScript.new("player.movement_speed", RulePatchScript.Operation.SET, 300.0))
	patches.append(RulePatchScript.new("player.dash_speed", RulePatchScript.Operation.ADD, 40.0))
	patches.append(RulePatchScript.new("player.attack_cooldown", RulePatchScript.Operation.MULTIPLY, 0.5))
	patches.append(RulePatchScript.new("enemy.max_active", RulePatchScript.Operation.SET, 12))
	patches.append(RulePatchScript.new("debug.show_hitboxes", RulePatchScript.Operation.ENABLE, true))

	var result: Variant = RuleResolverScript.resolve(base_state, patches)
	context.assert_true(result.is_ok(), "有効なパッチはエラーなしで解決される")
	context.assert_almost_equal(result.snapshot.get_float("player.movement_speed", 0.0), 300.0, 0.001, "SET が速度を置き換える")
	context.assert_almost_equal(result.snapshot.get_float("player.dash_speed", 0.0), 800.0, 0.001, "ADD がダッシュ速度へ加算される")
	context.assert_almost_equal(result.snapshot.get_float("player.attack_cooldown", 0.0), 0.1, 0.001, "MULTIPLY が攻撃間隔へ乗算される")
	context.assert_equal(result.snapshot.get_int("enemy.max_active", 0), 12, "整数値の SET が保持される")
	context.assert_equal(result.snapshot.get_bool("debug.show_hitboxes", false), true, "ENABLE が bool を true にする")

	var disabled_patches: Array = []
	disabled_patches.append(RulePatchScript.new("debug.show_hitboxes", RulePatchScript.Operation.ENABLE, true))
	disabled_patches.append(RulePatchScript.new("debug.show_hitboxes", RulePatchScript.Operation.DISABLE, false))
	var disabled_result: Variant = RuleResolverScript.resolve(base_state, disabled_patches)
	context.assert_equal(disabled_result.snapshot.get_bool("debug.show_hitboxes", true), false, "DISABLE が bool を false にする")

	var invalid_patches: Array = []
	invalid_patches.append(RulePatchScript.new("player.missing_value", RulePatchScript.Operation.SET, 100.0))
	var invalid_result: Variant = RuleResolverScript.resolve(base_state, invalid_patches)
	context.assert_true(not invalid_result.is_ok(), "存在しない rule path はエラーになる")

	var snapshot_copy: Dictionary = result.snapshot.to_dictionary()
	snapshot_copy["player"]["movement_speed"] = 1.0
	context.assert_almost_equal(result.snapshot.get_float("player.movement_speed", 0.0), 300.0, 0.001, "Snapshot の外部コピーは内部状態を汚さない")
	await context.process_frame
