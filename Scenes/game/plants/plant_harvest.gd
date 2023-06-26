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
		print(plantBody.name + " is spawning food")
		plantBody.stats.storedSugar -= 2.0
		var newPosition = plantBody.position + Vector2(
			randf_range(1.0, 50.0),
			randf_range(10.0, 60.0)
		)
		GameManager.spawn_new_object("plantFood", newPosition)
		emit_signal("Transitioned", "Harvest", "Idle")
	
func physics_update(_delta: float) -> void:
	pass
