extends Node
var game_world : Node2D

func _ready():
	open_main_menu()
	
func _on_Game_starting(game_scene : PackedScene):
	print("on_Game_starting")
	#Wait until the main menu is done doing its thing, (Playing its sound effect) 
	#	and then instance and start the game.
	await $MainMenu.tree_exited
	
	#Instance the game and start it! 
	#Keep a reference so we can free it later
	game_world = game_scene.instantiate()
	add_child(game_world)
	
	#Connect a signal ahead of time so that the main scene can handle things when the game ends.
	game_world.connect('end_game', Callable(self, 'open_main_menu'))
	
func open_main_menu():
	if game_world:
		game_world.queue_free()
	
	#Fade in to main menu
	var main_menu = load("res://Scenes/menu/MainMenu.tscn").instantiate()
	add_child(main_menu)
	main_menu.connect("starting", Callable(self, "_on_Game_starting"))
