extends Control

func _ready():
	hide()
	GameManager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)

func pause(do : bool) -> void:
	get_tree().paused = do
	visible = do

func _on_game_manager_toggle_game_paused(is_paused: bool):
	if(is_paused):
		show()
	else:
		hide()

func _on_resume_button_pressed():
	GameManager.gamePaused = false


func _on_save_button_pressed():
	GameManager.save_button()


func _on_load_button_pressed():
	GameManager.load_button()

func _on_exit_button_pressed():
	GameManager.quit_game_pressed()
