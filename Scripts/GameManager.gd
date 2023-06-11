extends Node

enum State {
	Play,
}

const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320
const GRAVITY: int = 200
const MAXO2MULTIPLIER: int = 2

var stats
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
	

func set_debug_overlay(debugOverlay):
	stats = debugOverlay

func set_current_level(tankData : TankData):
	currentTankData = tankData
	currentLevelHeight = tankData.height
	currentLevelWidth = tankData.width
	tankData.maxO2 = tankData.width * MAXO2MULTIPLIER
	print("setting height: " + str(currentLevelHeight))
	print("setting width: " + str(currentLevelWidth))
	print("setting MaxO2:" + str(tankData.maxO2))

func set_fish(myFish: Fish):
	currentFish = myFish
	
func clear_fish():
	currentFish = null

func request_o2(requested :float) -> float:
	return currentTankData.request_o2(requested)

func charge_o2(amountO2: float):
	currentTankData.charge_o2(amountO2)

func spawn_food(nutrition: Nutrition):
	pass

func spawn_dead_fish():
	pass
