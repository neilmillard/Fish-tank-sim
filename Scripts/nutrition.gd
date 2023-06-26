extends Resource
class_name Nutrition

@export var carbs: float = 0.0
@export var fats: float = 0.0
@export var proteins: float = 0.0
@export var size: float = 0.0

@export var processedCarbs: float = 0.0
@export var processedFats: float = 0.0
@export var processedProteins: float = 0.0


func _init(	myCarbs: float = 1.0, 
			myFats: float = 1.0, 
			myProteins: float = 1.0, 
			mySize: float = 1.0):
	carbs = myCarbs
	fats = myFats
	proteins = myProteins
	size = mySize
