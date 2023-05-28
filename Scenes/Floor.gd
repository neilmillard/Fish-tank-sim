extends Node2D

@onready var _floor = $Floor
var tank_data: TankData

func build(tank: TankData) -> void:
	tank_data = tank
	_floor.position.y = tank_data.height - GameManager.floorHeight
	
