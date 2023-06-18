extends Node2D

@export var mainGameScene : PackedScene
signal starting(game_scene_arg)

func start_game():
	emit_signal("starting", mainGameScene)
	queue_free()


func _on_new_game_button_button_up():
	GameManager.move_save_file()
	start_game()
	
func _on_load_game_button_button_up():
	start_game()
	
func _on_options_button_button_up():
	pass # Replace with function body.


func _on_exit_button_button_up():
	pass # Replace with function body.


