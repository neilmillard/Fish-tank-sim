extends Node2D

@export var mainGameScene : PackedScene
signal starting(game_scene_arg)

func _on_new_game_button_button_up():
	print("starting")
	emit_signal("starting", mainGameScene)
	queue_free()

func _on_options_button_button_up():
	pass # Replace with function body.


func _on_exit_button_button_up():
	pass # Replace with function body.
