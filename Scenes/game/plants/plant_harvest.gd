#PlantHarvest
extends PlantState

var harvestTimer: float

func enter(_msg:={}):
	harvestTimer = 0.0

func exit():
	pass

func update(delta: float) -> void:
	harvestTimer += delta
	if harvestTimer > 4.0:
		plantBody.stats.storedSugar -= 4.0
		var offset = Vector2(
			randf_range(1.0, 130.0),
			randf_range(-20.0, -70.0)
		)
		var newPosition = plantBody.position + offset
		GameManager.spawn_new_object("plantFood", newPosition)
		emit_signal("Transitioned", "Harvest", "Idle")
	
func physics_update(_delta: float) -> void:
	pass
