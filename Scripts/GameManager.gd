extends Node

enum State {
	Play,
}

signal spawn_new(objectName: String, position: Vector2, myNutrition: Nutrition)
signal spawn_placeable(object: Placeable)
signal run_test_button_pressed()
signal toggle_game_paused(is_paused: bool)
signal save_button_pressed()
signal load_button_pressed()
signal goto_main()
signal show_warning_message(message: String)
signal set_placeable_item(item: PlaceableItem)


const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320
const GRAVITY: int = 200
const MAXGASMULTIPLIER: float = 0.5
const SAVE_GAME_BASE_PATH = "user://save_file"
const STOMACH_CAPACITY_BASE: float = 10.0
const TANKTEMPDELTA: float = 0.1
const TANKMINTEMP: float = 14.0
const TANKMAXTEMP: float = 35.0
const MESSAGE_DISPLAY_TIME: float = 5

# Layers
const WALLS = 1
const FISH = 2
const FOOD = 3
const FLOOR = 4

# Resources
const BASE_PATH := "res://Resources"
const CHARACTER = "Character.tres"
var myFoodScene = ResourceLoader.load("res://Scenes/game/food/Food.tscn")
var myFishScene = ResourceLoader.load("res://Scenes/game/fish/Fish.tscn")
var foods := {}
var fishes := {}
var plants := {
	'GreenPlant': ResourceLoader.load("res://Scenes/game/plants/green_plant.tscn")
}

var filters := {
	'Gravel' = ResourceLoader.load("res://Scenes/game/equipment/GravelFilter.tscn"),
	'CanisterFilter' = ResourceLoader.load("res://Scenes/game/equipment/CanisterFilter.tscn")
}

var placeableItems := {
	'CanisterFilter' = ResourceLoader.load("res://Resources/filter/CanisterFilterCharacter.tres")
}

var debug
var currentState = State.Play
var currentLevelWidth: int = 2400
var currentLevelHeight: int = 1280
var floorHeight: int = 80
var wasteDecayRate: float = 0.0005
var ammoniaProcessRate: float = 0.002
var nitriteProcessRate: float = 0.0016
# bacteria growth rate, real = double in 13hrs
var bacteriaGrowthRate: float = 0.04
var nh3PpmHealthThreshold: float = 0.06 # 6%
# infectionEnergy amount of energy to increase health by 1
var infectionEnergy: float = 0.2
# How much energy required to grow (fish)
var growEnergy: float = 0.01
# How much growEnergy per unit of grow
var growRatio: float = 8.0
var waterFriction: float = 0.3

var currentTankData: TankData

# Resources
var flakeFood := 10
var liveFood := 10
var fish := 4
var credits := 10

# UI
var currentFish : Fish
var currentCameraTarget
	
var gamePaused: bool = false:
	get:
		return gamePaused
	set(value):
		gamePaused = value
		get_tree().paused = gamePaused
		emit_signal("toggle_game_paused", gamePaused)

func _ready() -> void:
	_find_entities_in(BASE_PATH)

func trigger_game_paused():
	gamePaused = !gamePaused

func save_button():
	emit_signal("save_button_pressed")

func load_button():
	emit_signal("load_button_pressed")
	
func quit_game_pressed():
	emit_signal("goto_main")

func run_water_test():
	emit_signal("run_test_button_pressed")

func display_warning_message(message: String) -> void:
	emit_signal("show_warning_message", message)

func set_debug_overlay(debugOverlay):
	debug = debugOverlay

func set_current_level(tankData : TankData):
	currentTankData = tankData
	currentLevelHeight = tankData.height
	currentLevelWidth = tankData.width
	tankData.maxGas = tankData.width * MAXGASMULTIPLIER
	print("setting height: " + str(currentLevelHeight))
	print("setting width: " + str(currentLevelWidth))
	print("setting MaxGas:" + str(tankData.maxGas))

func has_heater() -> bool:
	return currentTankData.heater

func temperatureModifer(optimumTemp: float, toleranceRange: float) -> float:
	# This returns a modifer based on the tank temperature
	# if temp == optimumTemp return 1.0
	# if temp within range return 1.0 -> 0.0.
	# if outside range return 0.0
	var temperature = get_tank_temp()
	if optimumTemp == temperature:
		return 1.0
	var diff = abs(temperature - optimumTemp)
	var modifier = 0.0
	if diff < toleranceRange:
		modifier = 1 - (diff / toleranceRange )**2
	return modifier

func set_tank_temp(delta: float) -> void:
	if currentTankData.heater:
		if currentTankData.currentTemp != currentTankData.targetTemp:
			if currentTankData.currentTemp > currentTankData.targetTemp:
				currentTankData.currentTemp -= delta * TANKTEMPDELTA
			else:
				currentTankData.currentTemp += delta * TANKTEMPDELTA

func set_tank_target_temp(diff: float) -> void:
	currentTankData.targetTemp += diff
	currentTankData.targetTemp = clamp(currentTankData.targetTemp, TANKMINTEMP, TANKMAXTEMP)
	
func get_tank_temp() -> float:
	return currentTankData.currentTemp

func new_fish_resource(type: String = "OrangeFish") -> Fish:
	var isMale = randf() > 0.5
	var myFishRes = Fish.new(type, isMale, 95.0, 0.5)
	currentTankData.add_fish(myFishRes)
	return myFishRes

func new_food_resource(type: String ="FlakeFood") -> Food:
	var myFoodRes = Food.new(type)
	currentTankData.add_food(myFoodRes)
	return myFoodRes

func new_filter_resource(type: String) -> Filter:
	var myFilterRes = Filter.new(type)
	currentTankData.add_filter(myFilterRes)
	return myFilterRes

func new_resource(category: String, type: String) -> Resource:
	match category:
		"Filter":
			return new_filter_resource(type)
		"Food":
			return new_food_resource(type)
		"Fish":
			return new_fish_resource(type)
		_:
			print("Category: %s Not found for GameManager.new_resource" % category)
			return

func remove_food_resource(myFood: Food) -> void:
	currentTankData.remove_food(myFood)

func currentFoodInTank() -> float:
	return len(currentTankData.food)
	
func currentFishInTank() -> float:
	return len(currentTankData.fish)

func remove_fish_resource(myFish: Fish) -> void:
	currentTankData.remove_fish(myFish)
	
func new_plant_resource(type: String = "GreenPlant") -> Plant:
	var myPlantRes = Plant.new(type)
	currentTankData.add_plant(myPlantRes)
	return myPlantRes

func remove_plant_resource(myPlant: Plant) -> void:
	currentTankData.remove_plant(myPlant)

func set_fish(myFish: Fish):
	currentFish = myFish
	
func clear_fish():
	currentFish = null

func request_o2(requested :float) -> float:
	return currentTankData.request_o2(requested)

func charge_o2(amountO2: float):
	currentTankData.charge_o2(amountO2)

func get_nh3_ppm() -> float:
	# This will be something like 40.0 / 800.0 = 1/20 = 5%
	var ppm = currentTankData.currentNH3 / currentTankData.maxGas
	return ppm

func get_no2_ppm() -> float:
	var ppm = currentTankData.currentNO2 / currentTankData.maxGas
	return ppm

func get_no3_ppm() -> float:
	var ppm = currentTankData.currentNO3 / currentTankData.maxGas
	return ppm

func water_change() -> void:
	currentTankData.water_change(0.2)

func spawn_fishfood(myPosition: Vector2, myNutrition: Nutrition):
	spawn_new_object("FishFood", myPosition, myNutrition)

func spawn_placeable_object(object: Placeable) -> void:
	emit_signal("spawn_placeable", object)
	
func spawn_new_object(objectName: String, position: Vector2 = Vector2.ZERO, myNutrition: Nutrition = null):
	emit_signal("spawn_new", objectName, position, myNutrition)

func place_placeable_item(item: String) -> void:
	var myItem = placeableItems[item]
	emit_signal("set_placeable_item", myItem)

func get_fish_mates(type: String, isMale: bool) -> Array[Fish]:
	var mates: Array[Fish] = []
	for _fish in currentTankData.fish:
		if currentTankData.fish[_fish].type == type and currentTankData.fish[_fish].isMale == isMale:
			mates.append(currentTankData.fish[_fish])
	return mates

# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return GameManager.SAVE_GAME_BASE_PATH + extension

func move_save_file():
	var save_path := GameManager.get_save_path()
	var backup_path : = save_path + ".bak"
	if ResourceLoader.exists(backup_path):
		DirAccess.remove_absolute(backup_path)

	DirAccess.rename_absolute(save_path, backup_path)
	
func _find_entities_in(path: String) -> void:
	var directory := DirAccess.open(path)

	if directory:
		var error := directory.list_dir_begin()
		if error != OK:
			print("Library Error: %s" % error)
			return

		var filename := directory.get_next()

		while filename != "":
			if directory.current_is_dir():
				_find_entities_in("%s/%s" % [directory.get_current_dir(), filename])
			else:
				if filename.ends_with("Fish" + CHARACTER):
					fishes[filename.replace(CHARACTER, "")] = load(
						"%s/%s" % [directory.get_current_dir(), filename]
					)
				if filename.ends_with("Food" + CHARACTER):
					foods[filename.replace(CHARACTER, "")] = load(
						"%s/%s" % [directory.get_current_dir(), filename]
					)
				
			filename = directory.get_next()
