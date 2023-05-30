extends Resource

class_name TankData

@export var width: int
@export var height: int
var heater: bool
var availableO2: float = 0.0

var maxO2: float
var fish = []
var food = []
var plants = []
var chemistry = []

func requestO2(requestedO2 :float) -> float:
	var provided = 0.0
	if availableO2 > requestedO2:
		provided = requestedO2
	else:
		provided = availableO2
	
	availableO2 -= provided
	return provided

func chargeO2(newO2: float):
	availableO2 += newO2
	availableO2 = clampf(availableO2, 5.0, maxO2)
