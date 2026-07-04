extends RefCounted

const SeededRngScript := preload("res://src/core/seeded_rng.gd")


func run(context) -> void:
	var first: Variant = SeededRngScript.new(12345)
	var second: Variant = SeededRngScript.new(12345)
	var first_values: Array[int] = []
	var second_values: Array[int] = []
	for index in range(8):
		first_values.append(first.next_int(0, 100000))
		second_values.append(second.next_int(0, 100000))
	context.assert_equal(first_values, second_values, "同じ seed は同じ整数列を返す")

	var different: Variant = SeededRngScript.new(54321)
	var different_values: Array[int] = []
	for index in range(8):
		different_values.append(different.next_int(0, 100000))
	context.assert_not_equal(first_values, different_values, "違う seed は違う整数列を返す")

	var ranged: Variant = SeededRngScript.new(77)
	for index in range(40):
		var value: int = ranged.next_int(3, 7)
		context.assert_true(value >= 3 and value <= 7, "next_int は指定範囲に収まる")

	var float_rng: Variant = SeededRngScript.new(88)
	for index in range(20):
		var float_value: float = float_rng.next_float_range(-2.0, 2.0)
		context.assert_true(float_value >= -2.0 and float_value <= 2.0, "next_float_range は指定範囲に収まる")

	context.assert_equal(SeededRngScript.new(1).choose_index(0), -1, "空の選択肢は -1 を返す")
	await context.process_frame
