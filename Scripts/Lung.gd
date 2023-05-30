extends Node2D
class_name Lung

# This class tracks the amount of Oxygen
@export var maxO2: float = 100.0

var currentO2: float = 5.0
var currentCO2: float = 0.0
var airExchangeRate: float = 1.0

func _process(delta: float) -> void:
	var requestedO2 = delta * airExchangeRate
	if currentO2 + requestedO2 > maxO2:
		requestedO2 = maxO2 - currentO2
	var actualO2 = GameManager.requestO2(requestedO2)
	currentO2 = currentO2 + actualO2
	
func requestO2(requestedO2: float) -> float:
	var provided = 0.0
	if currentO2 > requestedO2:
		provided = requestedO2
	else:
		provided = currentO2
	
	currentO2 -= provided
	return provided
