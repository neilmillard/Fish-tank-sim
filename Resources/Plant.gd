class_name Plant
extends Resource

@export var id: int
@export var type: String
@export var currentHealth: float
@export var globalPosition: Vector2
@export var growStage: int
@export var storedSugar: float

func _init(	p_type: String = "GreenPlant", 
			p_currentHealth: float = 100.0, 
			p_growStage: int = 0,
			p_storedSugar: float = 0.0):
	id = randi() % 1000000
	type = p_type
	currentHealth = 100
	growStage = p_growStage
	storedSugar = p_storedSugar
