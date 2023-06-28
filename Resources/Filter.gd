extends Resource
class_name Filter

@export var id: int
@export var type: String
@export var globalPosition: Vector2
@export var currentBacteriaSomonas: float
@export var currentBacteriaBacter: float

func _init(p_type = "Gravel", p_bacter = 5.0, p_somanas = 1.0):
	id = randi() % 1000000
	type = p_type
	globalPosition = Vector2.ZERO
	currentBacteriaBacter = p_bacter
	currentBacteriaSomonas = p_somanas
