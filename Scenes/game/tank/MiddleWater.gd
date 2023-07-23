extends Node2D
class_name MiddleWater

# This script manages the objects in the middle water Layer
# Our main concerns are the fish, plants and water quality
var tank_data: TankData
var surfaceO2TransferEfficiency = 0.0020
var surface: float = 29.0
var foodPinch: int = 4
var wallsWidth: float = 60.0

func _ready():
	GameManager.connect("spawn_new", _on_spawn_new_object)

func _process(delta):
	calc_O2_surface_transfer(delta)
	GameManager.set_tank_temp(delta)


func build(tank: TankData) -> void:
	tank_data = tank
	add_vertical_wall(tank_data.width + (wallsWidth/2), tank_data.height + 160, (tank_data.height - 80) / 2.0)
	add_vertical_wall(0 - (wallsWidth/2), tank_data.height + 160, (tank_data.height - 80) / 2.0)
	build_navmesh(
		Vector2(0,0), 
		Vector2(tank_data.width, tank_data.height), 
		GameManager.floorHeight
		)
	spawn_fishes(tank_data)
	spawn_foods(tank_data)
	spawn_plants(tank_data)
	spawn_filters(tank_data)
	
# add a collisionshape2d at the coords with fixed width and half heigh
func add_vertical_wall(x: float, y: float, y_pos: float):
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
	_wall.position = Vector2(x, y_pos)

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


func _on_spawn_new_object(
		objectName: String, 
		p_position: Vector2 = Vector2.ZERO,
		p_nutrition: Nutrition = null):
	if objectName == "FlakeFood":
		spawn_flakefood()
		return
	
	if objectName == "FishFood":
		print("called spawn_new_object with FishFood")
		return
		var myObj = spawn_obj(GameManager.foods["flakeFood"], p_position)
		myObj.nutritionValue = p_nutrition
		return
		
	if objectName in GameManager.foods:
		var spawnLocation = randf_range(100, GameManager.currentLevelWidth - 100)
		spawn_food(null,objectName,Vector2(spawnLocation + randi_range(-30, 30), surface))
		return
		
	if objectName == "PlantFood":
		spawn_obj(GameManager.foods["PlantFood"], p_position)
		return
	
	if objectName == "OrangeFish":
		spawn_fish(null, objectName, p_position)
		return
	
	if objectName == "GreenFish":
		spawn_fish(null, objectName, p_position)
		return
	
	if objectName == "GreenPlant":
		spawn_plant(null, objectName)
		return
	
	print("Error: ObjectName not defined " + objectName)
		
	
func spawn_fishes(tank: TankData):
	for myFishIndex in tank.fish:
		spawn_fish(tank.fish[myFishIndex])

func spawn_foods(tank: TankData):
	for myFoodIndex in tank.food:
		spawn_food(tank.food[myFoodIndex])
			
func spawn_plants(tank: TankData):
	for myPlantIndex in tank.plants:
		spawn_plant(tank.plants[myPlantIndex])

func spawn_filters(tank: TankData):
	for myFilterIndex in tank.filters:
		spawn_filter(tank.filters[myFilterIndex])

func update_gravel_filter():
	$GravelFilter.stats = tank_data.get_gravel_filter_stats()

func spawn_filter(stats: Filter = null, type: String = "Generic"):
	var myFilterScene: PackedScene
	var myPosition := Vector2.ZERO
	if stats:
		myFilterScene = GameManager.filters[stats.type]
		myPosition = stats.globalPosition
	else:
		myFilterScene = GameManager.filters[type]
	var myFilter = spawn_obj(myFilterScene, myPosition)
	if stats:
		myFilter.stats = stats

func spawn_food(foodStats: Food, type: String ="FlakeFood", myPosition: Vector2 = Vector2.ZERO):
	var myFoodCharacter : FoodCharacter
	
	if foodStats:
		myPosition = foodStats.globalPosition
		myFoodCharacter = GameManager.foods[foodStats.type]
		
	else:
		foodStats = GameManager.new_food_resource(type)
		foodStats.globalPosition = myPosition
		myFoodCharacter = GameManager.foods[type]
		foodStats.sinkTimerDuration = myFoodCharacter.sinkTime
		foodStats.rotTimerDuration = myFoodCharacter.rotTime
		
	var myFood = spawn_obj(GameManager.myFoodScene, myPosition)
	myFood.stats = foodStats
	myFood.myCharacter = myFoodCharacter
	
func spawn_flakefood():
	var spawnLocation = randf_range(100, GameManager.currentLevelWidth - 100)
	for n in range(1, foodPinch):
		spawn_food(null,"FlakeFood",Vector2(spawnLocation + randi_range(-30, 30), surface))
#		spawn_obj(GameManager.foods["flakeFood"],Vector2(spawnLocation + randi_range(-30, 30), surface))

func spawn_plant(plantStats: Plant = null, type: String = "GreenPlant"):
	var myPosition: Vector2
	var myPlantScene: PackedScene
	if plantStats:
		myPosition = plantStats.globalPosition
		myPlantScene = GameManager.plants[plantStats.type]
	else:
		var spawnLocation = randf_range(100, GameManager.currentLevelWidth - 100)
		var randomHeight = randf_range(70, 150)
		myPosition = Vector2(spawnLocation, GameManager.currentLevelHeight - randomHeight)
		myPlantScene = GameManager.plants[type]
	var myPlant = spawn_obj(myPlantScene, myPosition)
	if plantStats:
		myPlant.stats = plantStats

func spawn_fish(fishStats: Fish = null, type: String ="OrangeFish", myPosition: Vector2 = Vector2.ZERO):	
	var myFishCharacter : FishCharacter
	if fishStats:
		myPosition = fishStats.globalPosition
		myFishCharacter = GameManager.fishes[fishStats.type]
	else:
		fishStats = GameManager.new_fish_resource(type)
		myFishCharacter = GameManager.fishes[type]
		if myPosition == Vector2.ZERO:
			myPosition = Vector2(randf_range(50,GameManager.currentLevelWidth - 100),
							randf_range(50, 300))
	
	var myFish = spawn_obj(GameManager.myFishScene, myPosition)
	myFish.stats = fishStats
	myFish.myCharacter = myFishCharacter
	
func spawn_obj(obj : PackedScene, where : Vector2) -> Node2D:
	var myObject = obj.instantiate()
	add_child.call_deferred(myObject)
	myObject.position = where
	return myObject
	
func calc_O2_surface_transfer(delta):
	var newO2 = delta * GameManager.currentLevelWidth * surfaceO2TransferEfficiency
	GameManager.charge_o2(newO2)
	
