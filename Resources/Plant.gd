class_name Plant
extends Resource

@export var id: int
@export var type: String
@export var currentHealth: float
@export var globalPosition: Vector2
@export var growStage: int

func _init(p_type: String = "GreenPlant", p_currentHealth: float = 100.0, growStage: int = 0):
	id = randi() % 1000000
	type = p_type
	currentHealth = 100
	growStage = 0
