extends RefCounted

const GameScript := preload("res://src/run/game.gd")


func run(context) -> void:
	var game: Variant = GameScript.new()
	context.root.add_child(game)
	await context.process_frame

	var first_root: Node2D = game.get_session_root()
	context.assert_true(first_root != null and is_instance_valid(first_root), "起動時に session root が作られる")
	context.assert_equal(game.get_status(), 0, "起動時の状態は PLAYING")
	context.assert_equal(game.get_rule_snapshot().get_int("enemy.max_active", -1), 24, "ゲームが RuleSnapshot の敵上限を読める")

	game.start_run(777)
	await context.process_frame
	var second_root: Node2D = game.get_session_root()
	context.assert_true(second_root != null and is_instance_valid(second_root), "リスタート後にも session root が作られる")
	context.assert_not_equal(second_root, first_root, "リスタートで session root が作り直される")
	context.assert_true(not is_instance_valid(first_root), "古い session root は破棄される")
	context.assert_equal(game.get_status(), 0, "リスタート後の状態は PLAYING")

	for index in range(3):
		game.start_run(777)
		await context.process_frame
	context.assert_true(game.count_session_children() > 0, "連続リスタート後も session root にゲーム要素がある")
	context.assert_true(context.get_nodes_in_group("chaser").size() <= game.get_rule_snapshot().get_int("enemy.max_active", 24), "敵数は上限以下に収まる")

	game.queue_free()
	await context.process_frame
