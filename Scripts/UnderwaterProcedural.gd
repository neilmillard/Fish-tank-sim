extends Node2D
class_name UnderwaterPrecedural


@export var flakeFood: Food


@onready var chunk_layers = get_children()

var tank_data : TankData

	
func build(tank: TankData) -> void:
	tank_data = tank
	
	for layer in chunk_layers:
		layer.build(tank_data)
