extends Node2D
class_name Stomach
# This receives Carbs, Protein and Fat and turns it into available energy
# The process also creates waste products of undigested inputs
# food stored in the stomach takes a while to process, so we have a capacity

# capacity of this stomach
@export var capacity: float = 10.0
# percentage of full capacity processed per second
@export var processingSpeed: float = 0.03
# percentage of size that is waste
@export var processingEfficiency: float = 0.60

const carbEnergy: float = 1.0
const fatEnergy: float = 3.0
const proteinEnergy: float = 1.0

var storedFood:= []
var storedWaste: float = 0.0
var storedEnergy: float = 4.0

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
		print("Received food " + str(nutritionValue.size))
		storedFood.append(nutritionValue)

# tells the stomach to expell this amount of waste
func flush_waste(amount: float) -> float:
	var wasteFlushed = min(amount, storedWaste)
	storedWaste -= wasteFlushed
	return wasteFlushed

func get_energy(energyRequired: float) -> float:
	var energyAvailable = min(energyRequired, storedEnergy)
	storedEnergy -= energyAvailable
	return energyAvailable

func _process(delta: float) -> void:
	process_food(delta)
	
func process_food(delta: float) -> void:
	# we need storedFood
	# each call we get processingSpeed * delta as a percent of storedFood
	if len(storedFood) == 0:
		return
	
	var currentNutrition = storedFood[0]
	var processAmount: float = 1.0 / currentNutrition.size
	var processingPercent = processAmount * (processingSpeed) * delta
	var carbs = min(currentNutrition.carbs, currentNutrition.carbs * processingPercent)
	var fats = min(currentNutrition.fats, currentNutrition.fats * processingPercent)
	var proteins = min(currentNutrition.proteins, currentNutrition.proteins * processingPercent)
	currentNutrition.processedCarbs += carbs
	currentNutrition.processedFats += fats
	currentNutrition.processedProteins += proteins
	
	# Have we processed all the food?
	if currentNutrition.carbs > currentNutrition.processedCarbs:
		storedFood[0] = currentNutrition
	else:
		storedWaste += currentNutrition.size * processingEfficiency
		storedFood.pop_front()
		currentNutrition.free()
		currentNutrition = null
		
	storedEnergy += carbs * carbEnergy
	storedEnergy += fats * fatEnergy
	storedEnergy += proteins * proteinEnergy
	
	
