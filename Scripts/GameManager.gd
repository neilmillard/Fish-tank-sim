extends Node

enum State {
	Play,
}

const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320
const GRAVITY: int = 200

var currentState = State.Play
var currentLevelWidth: int = 2400
var currentLevelHeight: int = 1280
var floor: int = 1200
var currentTankData: TankData

# Resources
var flakeFood := 10
var liveFood := 0
var fish := 4
var credits := 10

# UI
var currentFish : Fish
var currentCameraTarget

func set_current_level(tankData : TankData):
	currentTankData = tankData
	currentLevelHeight = tankData.height
	currentLevelWidth = tankData.width
	print("setting height: " + str(currentLevelHeight))
	print("setting width: " + str(currentLevelWidth))

func set_fish(fish: Fish):
	currentFish = fish
	
func clear_fish():
	currentFish = null

