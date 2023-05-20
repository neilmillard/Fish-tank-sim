extends Node2D

# This script manages the objects in the middle water Layer
# Our main concerns are the fish, plants and water quality

var flakeFood : PackedScene = ResourceLoader.load("res://Scenes/flakeFood.tscn")
var fish : PackedScene = ResourceLoader.load("res://Scenes/fish.tscn")


var tank_data : TankData
var surface : float = 29.0

func build(tank: TankData) -> void:
	tank_data = tank
	
func spawn_flakefood():
	spawn_obj(flakeFood,Vector2(randf_range(50, GameManager.currentLevelWidth), surface))

func spawn_fish():
	spawn_obj(fish, Vector2(randf_range(50,950),randf_range(50, 300)))

func spawn_obj(obj : PackedScene, where : Vector2):
	var myObject := obj.instantiate()
	get_tree().root.add_child(myObject)
	myObject.position = where
	
