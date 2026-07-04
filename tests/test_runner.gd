extends SceneTree

const TEST_SCRIPTS = [
	preload("res://tests/unit/test_seeded_rng.gd"),
	preload("res://tests/unit/test_rule_resolver.gd"),
	preload("res://tests/smoke/test_game_restart.gd"),
	preload("res://tests/smoke/test_baseline_game.gd"),
]

var passed_count: int = 0
var failed_count: int = 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	print("SHIP//BREAK TESTS")
	for test_script in TEST_SCRIPTS:
		var test_instance: Variant = test_script.new()
		await test_instance.run(self)

	if failed_count == 0:
		print("SHIP//BREAK TESTS: PASS")
	else:
		print("SHIP//BREAK TESTS: FAIL")
		for failure in failures:
			push_error(failure)
	print("Assertions: %d passed, %d failed" % [passed_count, failed_count])
	quit(0 if failed_count == 0 else 1)


func assert_true(condition: bool, message: String) -> void:
	if condition:
		passed_count += 1
	else:
		_fail(message)


func assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual == expected:
		passed_count += 1
	else:
		_fail("%s actual=%s expected=%s" % [message, str(actual), str(expected)])


func assert_not_equal(actual: Variant, unexpected: Variant, message: String) -> void:
	if actual != unexpected:
		passed_count += 1
	else:
		_fail("%s unexpected=%s" % [message, str(unexpected)])


func assert_almost_equal(actual: float, expected: float, epsilon: float, message: String) -> void:
	if absf(actual - expected) <= epsilon:
		passed_count += 1
	else:
		_fail("%s actual=%s expected=%s epsilon=%s" % [message, actual, expected, epsilon])


func _fail(message: String) -> void:
	failed_count += 1
	failures.append(message)
