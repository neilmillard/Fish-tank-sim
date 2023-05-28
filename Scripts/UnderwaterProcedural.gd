extends Node2D
class_name UnderwaterPrecedural


@export var flakeFood: Food


@onready var chunk_layers = get_children()

var tank_data : TankData

func _ready():
	tank_data = load("res://Resources/default_tank.tres")
	build(tank_data)
	
	
func build(tank: TankData) -> void:
	GameManager.set_current_level(tank)
	tank_data = tank
	
	for layer in chunk_layers:
		if layer.has_method("build"):
			layer.build(tank_data)
		else:
			print("layer " + str(layer.get_path()) + " has no build method")
