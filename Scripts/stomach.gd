extends Resource
class_name Stomach
# This receives Carbs, Protein and Fat and turns it into available energy
# The process also creates waste products of undigested inputs
# food stored in the stomach takes a while to process, so we have a capacity
const carbEnergy: float = 1.0
const fatEnergy: float = 3.0
const proteinEnergy: float = 1.0

# capacity of this stomach
@export var capacity: float
# percentage of full capacity processed per second
@export var processingSpeed: float
# percentage of size that is waste
@export var processingEfficiency: float

@export var storedFood: Array[Nutrition]
@export var storedWaste: float
@export var storedNH3: float
@export var storedEnergy: float


func save():
	var save_dict = {
		"capacity": capacity,
		"processingSpeed": processingSpeed,
		"processingEfficiency": processingEfficiency,
		"storedFood": storedFood,
		"storedWaste": storedWaste,
		"storedNH3": storedNH3,
		"storedEnergy": storedEnergy
		}
	return save_dict

func _init(p_capacity = 10.0, p_processingSpeed = 0.03, p_processingEfficiency = 0.60):
	capacity = p_capacity
	processingSpeed = p_processingSpeed
	processingEfficiency = p_processingEfficiency
	storedFood = []
	storedWaste = 0.0
	storedNH3 = 0.0
	storedEnergy = 18.0

func _process(delta: float) -> void:
	process_food(delta)
	
func get_amount_food_stored():
	var foodSize = 0.0
	for food in storedFood:
		foodSize += food.size
	return foodSize

func get_stored_energy() -> float:
	return storedEnergy
	
func has_space_to_eat(size: float) -> bool:
	return size + get_amount_food_stored() + storedWaste <= capacity

func could_eat() -> bool:
	return get_amount_food_stored() + storedWaste <= capacity / 2
	
func receive_food(nutritionValue: Nutrition) -> void:
	if has_space_to_eat(nutritionValue.size):
		storedFood.append(nutritionValue)

func release_food():
	for nutrition in storedFood:
		GameManager.spawn_food(nutrition)
		nutrition.queue_free()
	

func receive_nh3(amount: float) -> void:
	storedNH3 += amount

# tells the stomach to expell this amount of waste
func flush_waste(amount: float) -> float:
	var wasteFlushed = minf(amount, storedWaste)
	storedWaste -= wasteFlushed
	return wasteFlushed

# tells the stomach to expell this amount of NH3
func flush_nh3(amount: float, realFlush: bool = false) -> float:
	var NH3Flushed = minf(amount, storedNH3)
	if realFlush:
		storedNH3 -= NH3Flushed
	return NH3Flushed

func get_energy(energyRequired: float) -> float:
	if energyRequired > storedEnergy:
		return 0.0
	storedEnergy -= energyRequired
	return energyRequired
	
func process_food(delta: float) -> void:
	# we need storedFood
	# each call we get processingSpeed * delta as a percent of storedFood
	# storedEnergy is incremented based on carbEnergy + fatEnergy + proteinEnergy
	# once processedCarbs > carbs
	# food is popped off the array
	if len(storedFood) == 0:
		return
	
	var currentNutrition = storedFood[0]
	var processAmount: float = 1.0 / currentNutrition.size
	var processingPercent = processAmount * (processingSpeed) * delta
	var carbs = minf(currentNutrition.carbs, currentNutrition.carbs * processingPercent)
	var fats = minf(currentNutrition.fats, currentNutrition.fats * processingPercent)
	var proteins = minf(currentNutrition.proteins, currentNutrition.proteins * processingPercent)
	currentNutrition.processedCarbs += carbs
	currentNutrition.processedFats += fats
	currentNutrition.processedProteins += proteins
	
	# Have we processed all the food?
	if currentNutrition.carbs > currentNutrition.processedCarbs:
		storedFood[0] = currentNutrition
	else:
		storedWaste += float(currentNutrition.size) * processingEfficiency
		storedFood.pop_front()
		currentNutrition = null
		
	storedEnergy += carbs * carbEnergy
	storedEnergy += fats * fatEnergy
	storedEnergy += proteins * proteinEnergy
	
	
