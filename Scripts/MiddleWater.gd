extends Node2D

# This script manages the objects in the middle water Layer
# Our main concerns are the fish, plants and water quality

var flakeFood : PackedScene = ResourceLoader.load("res://Scenes/flakeFood.tscn")
var fish : PackedScene = ResourceLoader.load("res://Scenes/fish.tscn")


var tank_data: TankData
var surface: float = 29.0
var foodPinch: int = 4
var wallsWidth: float = 60.0

func build(tank: TankData) -> void:
	tank_data = tank
	add_vertical_wall(tank_data.width, tank_data.height)
	
# add a collisionshape2d at the coords with fixed width and half heigh
func add_vertical_wall(x: float, y: float):
	var _wall = StaticBody2D.new()
	var _collisionShape = CollisionShape2D.new()
	var _collisionRectangle = RectangleShape2D.new()
	_collisionRectangle.size = Vector2(60, y)
	_collisionShape.shape = _collisionRectangle
	_wall.add_child(_collisionShape)
	add_child(_wall)
	_wall.set_collision_layer_value(1, true)
	_wall.set_collision_mask_value(2, true)
	_wall.set_collision_mask_value(3, true)
	_wall.position = Vector2(x, y / 2.0)
	
	
func spawn_flakefood():
	var spawnLocation = GameManager.currentLevelWidth - 100 #randf_range(100, GameManager.currentLevelWidth - 100)
	for n in range(1, foodPinch):
		spawn_obj(flakeFood,Vector2(spawnLocation + randi_range(-30, 30), surface))

func spawn_fish():
	spawn_obj(fish, Vector2(randf_range(50,950),randf_range(50, 300)))

func spawn_obj(obj : PackedScene, where : Vector2):
	var myObject := obj.instantiate()
	get_tree().root.add_child(myObject)
	myObject.position = where
	
