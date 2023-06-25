#PlantGrowing
extends PlantState

var growingTimer: float = 0.0

func enter(_msg:={}):
	growingTimer = 0.0

func exit():
	pass

func update(delta: float) -> void:
	growingTimer += delta
	if growingTimer > 5.0:
		plantBody.stats.storedSugar -= plantBody.growthCost * (plantBody.stats.growStage+1)
		plantBody.stats.growStage = min(plantBody.maxGrowStage, 
									plantBody.stats.growStage + 1)
		plantBody.sprite2D.frame = plantBody.stats.growStage
		emit_signal("Transitioned", "Growing", "Idle")

func physics_update(_delta: float) -> void:
	pass
