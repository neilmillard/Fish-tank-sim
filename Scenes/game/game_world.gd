extends Node2D

signal end_game

@export var start_tank : PackedScene
var current_tank : Node2D

func _ready():
	# Lets load up the tank
	_load_tank()
	GameManager.connect("load_button_pressed", _on_load_game_button_pressed)
	GameManager.connect("goto_main", Callable(self, "_on_goto_main"))

func _on_goto_main():
	emit_signal("end_game")

func _load_tank():
	current_tank = start_tank.instantiate()
	$Tanks.add_child(current_tank)

func _on_load_game_button_pressed():
	current_tank.queue_free()
	await current_tank.tree_exited
	_load_tank()

