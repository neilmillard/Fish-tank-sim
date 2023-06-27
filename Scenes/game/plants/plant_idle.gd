#PlantIdle
extends PlantState

# plant creates sugar and proteins in StateFeeding
# if enough sugars and protein, will grow
# once max growth, it will create food with carbs and protein
# plants can create fats, but only usually for seeds


func enter(_msg:={}):
	pass

func exit():
	pass

func update(_delta: float) -> void:
	if plantBody.stats.currentHealth <= 0.0:
		emit_signal("Transitioned", "Idle", "Dead")
		return
	
	if enough_sugar():
		if plantBody.stats.growStage < plantBody.maxGrowStage:
			emit_signal("Transitioned", "Idle", "Growing")
			return
		else:
			emit_signal("Transitioned", "Idle", "Harvest")
			return
		
	if available_food():
		emit_signal("Transitioned", "Idle", "Feeding")
	
func physics_update(_delta: float) -> void:
	pass

func available_food():
	return GameManager.currentTankData.currentNO3 > 1.0

func enough_sugar():
	return plantBody.stats.storedSugar > plantBody.growthThreshold * (plantBody.stats.growStage+1)
