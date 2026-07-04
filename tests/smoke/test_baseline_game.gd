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

	game.start_run(1842)
	await context.process_frame
	player = game.get_session_root().get_node("Player")
	player.take_damage(999)
	await context.process_frame
	context.assert_equal(game.get_status(), 2, "プレイヤーの耐久が0になると LOST になる")

	game.start_run(1842)
	await context.process_frame
	game._elapsed_seconds = game._run_duration_seconds
	game._physics_process(0.0)
	context.assert_equal(game.get_status(), 1, "制限時間まで生存すると WON になる")

	game.queue_free()
	await context.process_frame
