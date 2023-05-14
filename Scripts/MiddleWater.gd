extends Node2D

# This script manages the objects in the middle water Layer
# Our main concerns are the fish, plants and water quality

var tank_data : TankData


func build(tank: TankData) -> void:
	tank_data = tank
	
