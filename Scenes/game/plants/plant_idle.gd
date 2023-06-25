#PlantIdle
extends PlantState

func enter(_msg:={}):
	pass

func exit():
	pass

func update(_delta: float) -> void:
	# plant will only change from idle, if food is available
	# if enough sugars, will grow
	if plantBody.stats.currentHealth <= 0.0:
		emit_signal("Transitioned", "Idle", "Dead")
		return
	if enough_sugar() and plantBody.stats.growStage < plantBody.maxGrowStage:
		emit_signal("Transitioned", "Idle", "Growing")
		return
	if available_food():
		emit_signal("Transitioned", "Idle", "Feeding")
	
func physics_update(_delta: float) -> void:
	pass

func available_food():
	return GameManager.currentTankData.currentNO3 > 1.0

func enough_sugar():
	return plantBody.stats.storedSugar > plantBody.growthThreshold * (plantBody.stats.growStage+1)
