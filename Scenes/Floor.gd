extends Node2D

@onready var _floor = $Floor
var tank_data: TankData

func build(tank: TankData) -> void:
	tank_data = tank
	_floor.position.x = tank_data.width / 2.0
	$Floor/TileMap.position.x = -1.0 * (tank_data.width / 2.0)
	_floor.position.y = tank_data.height - GameManager.floorHeight
	var x = GameManager.currentLevelWidth
	var _collisionShape = CollisionShape2D.new()
	var _collisionRectangle = RectangleShape2D.new()
	_collisionRectangle.size = Vector2(x, 60)
	_collisionShape.shape = _collisionRectangle
	_collisionShape.position.y = 60
	_floor.add_child(_collisionShape)
	
