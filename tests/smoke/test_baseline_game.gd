extends RefCounted

const GameScript = preload("res://src/run/game.gd")
const ProjectileScript = preload("res://src/combat/projectile.gd")


func run(context) -> void:
	var game: Variant = GameScript.new()
	context.root.add_child(game)
	await context.process_frame
	await context.physics_frame

	var player: Variant = game.get_session_root().get_node("Player")
	var first_chaser: Variant = context.get_nodes_in_group("chaser")[0]
	var starting_health: int = player.health
	first_chaser.global_position = player.global_position + Vector2(player.hit_radius + first_chaser.contact_radius - 2.0, 0.0)
	game._resolve_enemy_contact()
	context.assert_true(player.health < starting_health, "Chaser の接触でプレイヤーの耐久が減る")
	context.assert_true(game.get_session_root().get_node("FeedbackFx").active_count() > 0, "被弾時に視覚フィードバックが出る")
	context.assert_true(game.get_danger_intensity() > 0.7, "Chaser が近いと危険度が上がる")

	first_chaser.global_position = player.global_position + Vector2(640.0, 0.0)
	context.assert_almost_equal(game.get_danger_intensity(), 0.0, 0.001, "Chaser が遠いと危険度はゼロに戻る")

	game.start_run(1842)
	await context.process_frame
	await context.physics_frame
	player = game.get_session_root().get_node("Player")
	first_chaser = context.get_nodes_in_group("chaser")[0]
	first_chaser.health = 1
	var projectile: Variant = ProjectileScript.new()
	projectile.configure(first_chaser.global_position, Vector2.RIGHT, 0.0, 1)
	game.get_session_root().add_child(projectile)
	await context.process_frame
	game._resolve_projectile_enemy_hits()
	await context.process_frame
	context.assert_true(not is_instance_valid(first_chaser), "弾の命中で Chaser を倒せる")
	context.assert_true(game.get_session_root().get_node("FeedbackFx").active_count() > 0, "命中時に視覚フィードバックが出る")

	game.start_run(1842)
	await context.process_frame
	player = game.get_session_root().get_node("Player")
	player.take_damage(999)
	await context.process_frame
	context.assert_equal(game.get_status(), 2, "プレイヤーの耐久が0になると LOST になる")
	var lost_touch := InputEventScreenTouch.new()
	lost_touch.pressed = true
	lost_touch.position = Vector2(100.0, 100.0)
	game._input(lost_touch)
	context.assert_equal(game.get_status(), 0, "失敗画面タップで新しいランへ戻る")

	game.start_run(1842)
	await context.process_frame
	game._elapsed_seconds = game._run_duration_seconds
	game._physics_process(0.0)
	context.assert_equal(game.get_status(), 1, "制限時間まで生存すると WON になる")
	context.assert_true(game.is_debug_interruption_showing(), "成功時にデバッグ割り込み画面が出る")
	var debug_overlay: Variant = game.get_node("Hud").get_node("DebugInterruptionOverlay")
	context.assert_true(debug_overlay.is_workaround_selectable(), "成功画面では WORKAROUND だけ選択できる")

	var restart_touch := InputEventScreenTouch.new()
	restart_touch.pressed = true
	restart_touch.position = Vector2(100.0, 100.0)
	game._input(restart_touch)
	context.assert_equal(game.get_status(), 1, "成功画面の背景タップだけでは WORKAROUND を適用しない")

	debug_overlay.select_workaround()
	context.assert_equal(game.get_status(), 0, "WORKAROUND 選択で新しいランへ戻る")
	context.assert_true(not game.is_debug_interruption_showing(), "リスタート後はデバッグ割り込み画面が消える")
	context.assert_true(game.is_time_desync_workaround_enabled(), "WORKAROUND 選択で TIME DESYNC WORKAROUND が有効になる")
	context.assert_equal(game.get_rule_snapshot().get_bool("world.time_desync_enabled", false), true, "次のランへ TIME DESYNC のルールパッチが入る")
	game._elapsed_seconds = 0.55
	context.assert_true(game.get_time_desync_intensity() > 0.5, "TIME DESYNC の発生中は強度が上がる")
	context.assert_true(game.get_world_time_scale() < 1.0, "TIME DESYNC 中は世界時間が遅くなる")

	game.start_run(1842)
	await context.process_frame
	context.assert_almost_equal(game.get_anomaly_intensity(), 0.0, 0.001, "序盤は異常予兆が出ない")
	game._elapsed_seconds = game._run_duration_seconds - 5.0
	context.assert_true(game.get_anomaly_intensity() > 0.0, "終盤は異常予兆が出る")

	game.queue_free()
	await context.process_frame
