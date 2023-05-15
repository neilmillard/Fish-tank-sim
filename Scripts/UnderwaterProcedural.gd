extends Node2D
class_name UnderwaterPrecedural

const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320

@export var flakeFood: Food

@onready var chunk_layers = get_children()

var tank_data : TankData

func build(tank: TankData) -> void:
	tank_data = tank
	
	for layer in chunk_layers:
		layer.build(tank_data)
