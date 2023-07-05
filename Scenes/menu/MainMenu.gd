extends Node2D

@export var mainGameScene : PackedScene
signal starting(game_scene_arg: PackedScene)
	
func _ready():
	print("main menu ready")
	
func start_game():
	emit_signal("starting", mainGameScene)
	queue_free()


func _on_new_game_button_button_up():
	print("new game pressed")
	GameManager.move_save_file()
	start_game()
	
func _on_load_game_button_button_up():
	print("load game pressed")
	start_game()
	
func _on_options_button_button_up():
	print("options pressed")
	pass # Replace with function body.


func _on_exit_button_button_up():
	print("quit pressed")
	get_tree().quit()


