extends Node2D
class_name Stomach
# This receives Carbs, Protein and Fat and turns it into available energy
# The process also creates waste products of undigested inputs
# food stored in the stomach takes a while to process, so we have a capacity

# capacity of this stomach
@export var capacity: float = 50.0
# percentage of full capacity processed per second
@export var processingSpeed: float = 0.1
# percentage of size that is waste
@export var processingEfficiency: float = 0.60

const carbEnergy: float = 1.0
const fatEnergy: float = 3.0
const proteinEnergy: float = 1.0
const sizeEnergy: float = 1.0

var storedFood: Nutrition = Nutrition.new()
var storedWaste: float = 0.0
var storedEnergy: float = 0.0

func has_space_to_eat(size: float) -> bool:
	return size + storedFood.size + storedWaste < capacity
	
func receive_food(nutritionValue: Nutrition) -> void:
	if nutritionValue.size + storedFood.size <= capacity:
		storedFood.carbs += nutritionValue.carbs
		storedFood.fats += nutritionValue.fats
		storedFood.proteins += nutritionValue.proteins
		storedFood.size += nutritionValue.size

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
	# we need storedFood
	# each call we get processingSpeed * delta as a percent of storedFood
	if storedFood.size < 0.001:
		return
	
	var processingPercent = (capacity / storedFood.size) * (processingSpeed / 1000) * delta
	var carbs = min(storedFood.carbs, storedFood.carbs * processingSpeed)
	var fats = min(storedFood.fats, storedFood.fats * processingSpeed)
	var proteins = min(storedFood.proteins, storedFood.proteins * processingSpeed)
	var size = min(storedFood.size, capacity * (processingSpeed) / 1000)
	
	storedFood.carbs -= carbs
	storedFood.fats -= fats
	storedFood.proteins -= proteins
	storedFood.size -= size
	
	storedEnergy += carbs * carbEnergy
	storedEnergy += fats * fatEnergy
	storedEnergy += proteins * proteinEnergy
	
	storedWaste += size * processingEfficiency
	
