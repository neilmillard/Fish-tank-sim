class_name PlantState
extends State

var plantBody: PlantBody

func _ready() -> void:
	await owner.ready
	plantBody = owner as PlantBody
	assert(plantBody != null)
	
