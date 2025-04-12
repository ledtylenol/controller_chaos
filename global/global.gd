extends Node

var game: World

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_R and event.is_pressed():
		game.reload_world()
