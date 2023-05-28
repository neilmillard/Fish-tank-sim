extends Node2D
class_name MiddleWater

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
	add_vertical_wall(tank_data.width + (wallsWidth/2), tank_data.height)
	add_vertical_wall(0 - (wallsWidth/2), tank_data.height)
	build_navmesh(
		Vector2(0,0), 
		Vector2(tank_data.width, tank_data.height), 
		GameManager.floorHeight
		)
	
# add a collisionshape2d at the coords with fixed width and half heigh
func add_vertical_wall(x: float, y: float):
	var _wall = StaticBody2D.new()
	var _collisionShape = CollisionShape2D.new()
	var _collisionRectangle = RectangleShape2D.new()
	var _sprite = Sprite2D.new()
	var _texture = PlaceholderTexture2D.new()
	_texture.size = Vector2(60, y)
	_sprite.texture = _texture
	_collisionRectangle.size = Vector2(60, y)
	_collisionShape.shape = _collisionRectangle
	_wall.add_child(_collisionShape)
	_wall.add_child(_sprite)
	add_child(_wall)
	_wall.set_collision_layer_value(1, true)
	_wall.set_collision_mask_value(2, true)
	_wall.set_collision_mask_value(3, true)
	_wall.position = Vector2(x, y / 2.0)

func build_navmesh(topLeft: Vector2, bottomRight: Vector2, floorHeight: int):
	var _floor = bottomRight.y - floorHeight
	var navRegion2D = NavigationRegion2D.new()
	var polygon = NavigationPolygon.new()
	var outline = PackedVector2Array([topLeft, Vector2(topLeft.x, _floor), 
				Vector2(bottomRight.x, _floor), Vector2(bottomRight.x, topLeft.y)])
	polygon.add_outline(outline)
	polygon.make_polygons_from_outlines()
	navRegion2D.navigation_polygon = polygon
	add_child(navRegion2D)

	
func spawn_flakefood():
	var spawnLocation = randf_range(100, GameManager.currentLevelWidth - 100)
	for n in range(1, foodPinch):
		spawn_obj(flakeFood,Vector2(spawnLocation + randi_range(-30, 30), surface))

func spawn_fish():
	spawn_obj(fish, Vector2(randf_range(50,GameManager.currentLevelWidth - 100),
							randf_range(50, 300)))

func spawn_obj(obj : PackedScene, where : Vector2):
	var myObject := obj.instantiate()
	get_tree().root.add_child(myObject)
	myObject.position = where
	
