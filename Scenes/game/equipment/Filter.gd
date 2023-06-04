extends Node2D
class_name Filter

# max Bacteria would be calculated based on media, surface area and such
@export var maxBacteria: float = 100.0

# Bacteria for NH3 -> NO2
var currentBacteriaSomonas: float = 1.0
# Bacteria for NO2 -> NO3
var currentBacteriaBacter: float = 1.0

# bacteria growth rate, real = double in 13hrs
var bacteriaGrowthRate: float

func _ready():
	GameManager.stats.add_property(self, "currentBacteriaSomonas", "round")
	GameManager.stats.add_property(self, "currentBacteriaBacter", "round")
	bacteriaGrowthRate = GameManager.bacteriaGrowthRate

func _process(delta):
	growBacteria(delta)
	processNH3(delta)
	processNO2(delta)

func growBacteria(delta: float) -> void:
	currentBacteriaBacter = minf(maxBacteria, currentBacteriaBacter + (delta * currentBacteriaBacter * bacteriaGrowthRate))
	currentBacteriaSomonas = minf(maxBacteria, currentBacteriaSomonas + (delta * currentBacteriaSomonas * bacteriaGrowthRate))
		
func processNH3(delta: float) -> void:
	# Bacteria Somonas uses 1.5 O2 and NH3, and spits out NO2 + H+
	var amount = delta * GameManager.ammoniaProcessRate * currentBacteriaSomonas
	var nh3 = GameManager.currentTankData.remove_nh3(amount)
	var o2Needed = nh3 * 1.5
	var o2 = GameManager.currentTankData.request_o2(o2Needed)
	var no2Created = nh3
	if o2 < o2Needed:
		# not enough oxygen to process either
		var nh3Excess = (o2Needed - o2) / 1.5
		GameManager.currentTankData.add_nh3(nh3Excess)
		no2Created -= nh3Excess
	GameManager.currentTankData.add_no2(no2Created)
	if no2Created < amount:
		# we didn't get enough "food" for the bacteria
		currentBacteriaSomonas = maxf(1.0, currentBacteriaSomonas - ((currentBacteriaSomonas * 0.02) * delta))
	GameManager.currentTankData.add_no2(no2Created)
	

func processNO2(delta: float) -> void:
	# Bacteria Bacter uses O2 and 2 x NO2, and spits out 2 NO3
	var amount = delta * GameManager.nitriteProcessRate * currentBacteriaBacter
	var no2 = GameManager.currentTankData.remove_no2(amount)
	var o2Needed = no2 / 2
	var o2 = GameManager.currentTankData.request_o2(o2Needed)
	var no3Created = no2
	if o2 < o2Needed:
		# not enough oxygen to process either
		var no2Excess = (o2Needed - o2) * 2
		GameManager.currentTankData.add_no2(no2Excess)
		no3Created -= no2Excess
	GameManager.currentTankData.add_no3(no3Created)
	
	if no3Created < amount:
		# we didn't get enough "food" for the bacteria
		currentBacteriaBacter = maxf(1.0, currentBacteriaBacter * (no3Created / amount))
	
	
func getSomonas()-> float:
	return currentBacteriaSomonas

func getBacter()-> float:
	return currentBacteriaBacter
