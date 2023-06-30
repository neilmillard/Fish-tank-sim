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
		myBody.stats.storedSugar -= myBody.growthCost * (myBody.stats.growStage+1)
		myBody.stats.growStage = min(myBody.maxGrowStage, 
									myBody.stats.growStage + 1)
		myBody.sprite2D.frame = myBody.stats.growStage
		emit_signal("Transitioned", "Growing", "Idle")

func physics_update(_delta: float) -> void:
	pass
