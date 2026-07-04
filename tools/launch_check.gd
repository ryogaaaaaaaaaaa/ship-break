extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	if main_scene == null:
		push_error("Main scene could not be loaded.")
		quit(1)
		return

	var game: Node = main_scene.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame

	if not game.has_method("get_status"):
		push_error("Main scene does not expose get_status().")
		quit(1)
		return

	game.queue_free()
	await process_frame
	print("SHIP//BREAK LAUNCH CHECK: PASS")
	quit(0)
