class_name Fish
extends Resource

# Fish management
@export var id: int
@export var type: String
@export var isMale: bool
@export var currentHealth: float
@export var fishSize: float
@export var myLung: Lung
@export var myStomach: Stomach
@export var globalPosition: Vector2

func _init(p_type = "OrangeFish", p_isMale = true, p_currentHealth = 95.0, p_fishSize = 1.0):
	id = randi() % 1000000
	type = p_type
	isMale = p_isMale
	currentHealth = p_currentHealth
	fishSize = p_fishSize
	myLung = Lung.new()
	myStomach = Stomach.new()
