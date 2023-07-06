#PlantFeeding
extends PlantState

var fedAmount: float = 0.0

func enter(_msg:={}):
	fedAmount = 0.0

func exit():
	pass

func update(delta: float) -> void:
	# grab NO3 -> output O2 and store Sugar
	# This is not reality. Photosynthesis creates glucose from 
	# CO2 and H2O with sunlight energy
	# NH4 is synthesized from NO3, which creates amino acids from glucose -> protein
	var no3Received = GameManager.currentTankData.remove_NO3(
									delta * myBody.processingRate * myBody.growthRate)
	if no3Received > 0.0:
		myBody.stats.storedSugar += no3Received
		GameManager.currentTankData.charge_o2(no3Received)
		fedAmount += no3Received
	
	if fedAmount > 0.5:
		emit_signal("Transitioned", "Feeding", "Idle")

func physics_update(_delta: float) -> void:
	pass
