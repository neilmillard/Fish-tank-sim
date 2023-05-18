extends Node

enum State {
	Play,
}

const CHUNK_HEIGHT: int = 128
const CHUNK_WIDTH: int = 320

var currentState = State.Play

# Resources
var flakeFood := 10
var liveFood := 0
var fish := 4
var credits := 10

# UI
var currentFish : Fish

func set_fish(fish: Fish):
	currentFish = fish
	
func clear_fish():
	currentFish = null

