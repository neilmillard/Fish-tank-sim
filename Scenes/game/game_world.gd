extends Node2D

signal end_game

@export var start_tank : PackedScene
var current_tank : Node2D

func _ready():
	# Lets load up the tank
	_load_tank()

func _on_goto_main():
	emit_signal("end_game")

func _load_tank():
	current_tank = start_tank.instantiate()
	$Tanks.add_child(current_tank)
	current_tank.connect("goto_main", Callable(self, "_on_goto_main"))
