#PlantFeeding
extends PlantState

var fedAmount: float = 0.0

func enter(_msg:={}):
	fedAmount = 0.0

func exit():
	pass

func update(delta: float) -> void:
	# grab NO3 -> output O2 and store Sugar
	var no3Received = GameManager.currentTankData.remove_NO3(delta * plantBody.processingRate)
	if no3Received > 0.0:
		plantBody.stats.storedSugar += no3Received
		GameManager.currentTankData.charge_o2(no3Received)
		fedAmount += no3Received
	
	if fedAmount > 1.0 or no3Received == 0.0:
		print(str(plantBody.stats.storedSugar))
		emit_signal("Transitioned", "Feeding", "Idle")

func physics_update(_delta: float) -> void:
	pass
