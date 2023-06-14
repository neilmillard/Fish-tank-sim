class_name TankData
extends Resource

@export var width: int
@export var height: int
@export var availableO2: float = 0.0
@export var currentWaste: float = 0.0
@export var currentNH3: float = 0.0
@export var currentNO2: float = 0.0
@export var currentNO3: float = 0.0

@export var heater: bool
@export var currentTemp: float

var maxO2: float
@export var fish := {}
@export var food := {}
@export var plants := {}
@export var filters := {}

func add_fish(myFish: Fish) -> void:
	fish[myFish.id] = myFish

func remove_fish(myFish: Fish) -> void:
	fish.erase(myFish.id)

func add_food(myFood: Food) -> void:
	food[myFood.id] = myFood

func remove_food(myFood: Food) -> void:
	food.erase(myFood.id)

func request_o2(requestedO2 :float) -> float:
	var returnValue = remove(requestedO2, availableO2)
	availableO2 = returnValue.y
	return returnValue.x
	
func remove(amount: float, currentValue: float) -> Vector2:
	var provided = 0.0
	if currentValue > amount:
		provided = amount
	else:
		provided = currentValue
	
	currentValue -= provided
	return Vector2(provided, currentValue)
	
func charge_o2(newO2: float):
	availableO2 += newO2
	availableO2 = clampf(availableO2, 5.0, maxO2)

func add_waste(amount: float) -> void:
	currentWaste += amount

func remove_waste(amount: float) -> float:
	var returnValue = remove(amount, currentWaste)
	currentWaste = returnValue.y
	return returnValue.x

func add_nh3(amount: float) -> void:
	currentNH3 += amount

func remove_nh3(amount: float) -> float:
	var returnValue = remove(amount, currentNH3)
	currentNH3 = returnValue.y
	return returnValue.x
	
func add_no2(amount: float) -> void:
	currentNO2 += amount

func remove_no2(amount: float) -> float:
	var returnValue = remove(amount, currentNO2)
	currentNO2 = returnValue.y
	return returnValue.x
	
func add_no3(amount: float) -> void:
	currentNO3 += amount

func remove_NO3(amount: float) -> float:
	var returnValue = remove(amount, currentNO3)
	currentNO3 = returnValue.y
	return returnValue.x
	
