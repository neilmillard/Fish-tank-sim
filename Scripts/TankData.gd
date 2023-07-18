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
@export var targetTemp: float = 20.0

var maxGas: float
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

func add_filter(myFilter: Filter) -> void:
	if myFilter.type == "Gravel":
		# only allowed one Gravel Filter per tank
		if get_gravel_filter_stats() != null:
			return
	filters[myFilter.id] = myFilter
	

func remove_filter(myFilter: Filter) -> void:
	filters.erase(myFilter.id)

func get_gravel_filter_stats() -> Filter:
	for idx in filters:
		if filters[idx].type == "Gravel":
			return filters[idx]
	return null

func add_plant(myPlant: Plant) -> void:
	plants[myPlant.id] = myPlant

func remove_plant(myPlant: Plant) -> void:
	plants.erase(myPlant.id)

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

func get_current_gas() -> float:
	return currentNH3 + currentNO2 + currentNO3 + availableO2

func get_gas_capacity(gasAmount: float) -> float:
	var waterGas = get_current_gas()
	if waterGas + gasAmount < maxGas:
		return gasAmount
	else:
		return max(0, maxGas - waterGas)
		
func charge_o2(newO2: float) -> float:
	var amountAdded = get_gas_capacity(newO2)
	availableO2 += amountAdded
	return amountAdded

func add_waste(amount: float) -> void:
	currentWaste += amount

func remove_waste(amount: float) -> float:
	var returnValue = remove(amount, currentWaste)
	currentWaste = returnValue.y
	return returnValue.x

func add_nh3(amount: float) -> float:
	var amount_added = get_gas_capacity(amount)
	currentNH3 += amount_added
	return amount_added

func remove_nh3(amount: float) -> float:
	var returnValue = remove(amount, currentNH3)
	currentNH3 = returnValue.y
	return returnValue.x
	
func add_no2(amount: float) -> float:
	var amountAdded = get_gas_capacity(amount)
	currentNO2 += amountAdded
	return amountAdded

func remove_no2(amount: float) -> float:
	var returnValue = remove(amount, currentNO2)
	currentNO2 = returnValue.y
	return returnValue.x
	
func add_no3(amount: float) -> float:
	var amountAdded = get_gas_capacity(amount)
	currentNO3 += amountAdded
	return amountAdded

func remove_NO3(amount: float) -> float:
	var returnValue = remove(amount, currentNO3)
	currentNO3 = returnValue.y
	return returnValue.x
	
func water_change(percent: float):
	# removes a percentage of bacteria
	# water gas
	# waste (until we clean filter button)
	var filter = get_gravel_filter_stats()
	filter.water_change(percent)
	
	currentNH3 -= currentNH3 * percent
	currentNO2 -= currentNO2 * percent
	currentNO3 -= currentNO3 * (percent / 2.0)
	currentWaste -= currentWaste * percent
