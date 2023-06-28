extends Node

enum State {
	Play,
}

signal spawn_new(objectName: String, position: Vector2)
signal toggle_game_paused(is_paused: bool)
signal save_button_pressed()
signal load_button_pressed()


const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320
const GRAVITY: int = 200
const MAXGASMULTIPLIER: float = 0.5
const SAVE_GAME_BASE_PATH = "user://save_file"

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
var nh3HealthThreshold: float = 40.0
# infectionEnergy amount of energy to increase health by 1
var infectionEnergy: float = 0.2
var waterFriction: float = 0.3

var currentTankData: TankData

# Resources
var flakeFood := 10
var liveFood := 0
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


func trigger_game_paused():
	gamePaused = !gamePaused

func save_button():
	emit_signal("save_button_pressed")

func load_button():
	emit_signal("load_button_pressed")
	
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

func new_fish_resource(type: String = "OrangeFish"):
	var myFishRes = Fish.new(type, true, 95.0, 1.0)
	currentTankData.add_fish(myFishRes)
	return myFishRes

func new_food_resource():
	var myFoodRes = Food.new()
	currentTankData.add_food(myFoodRes)
	return myFoodRes

func new_filter_resource(type: String):
	var myFilterRes = Filter.new(type)
	currentTankData.add_filter(myFilterRes)
	return myFilterRes
	
func remove_food_resource(myFood: Food) -> void:
	currentTankData.remove_food(myFood)

func new_plant_resource(type: String = "GreenPlant"):
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

func spawn_new_object(objectName: String, position: Vector2 = Vector2.ZERO):
	emit_signal("spawn_new", objectName, position)

func spawn_dead_fish():
	pass

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
	
