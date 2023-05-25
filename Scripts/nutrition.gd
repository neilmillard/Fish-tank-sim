extends Node2D
class_name Nutrition

@export var carbs: float = 0.0
@export var fats: float = 0.0
@export var proteins: float = 0.0
@export var size: float = 0.0

var processedCarbs: float = 0.0
var processedFats: float = 0.0
var processedProteins: float = 0.0


func setup(myCarbs: float, myFats: float, myProteins: float, mySize: float):
	carbs = myCarbs
	fats = myFats
	proteins = myProteins
	size = mySize
	return self
