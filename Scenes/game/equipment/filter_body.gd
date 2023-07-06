extends Node2D

# max Bacteria would be calculated based on media, surface area and such
@export var maxBacteria: float = 100.0
# stats track two types of bacteria
@export var stats: Filter
@export var type: String = "Generic"

# bacteria growth rate, real = double in 13hrs
var bacteriaGrowthRate: float

func _ready():
	# GameManager.stats.add_property(self, "currentBacteriaSomonas", "round")
	# GameManager.stats.add_property(self, "currentBacteriaBacter", "round")
	bacteriaGrowthRate = GameManager.bacteriaGrowthRate
	if !stats:
		if type.length() > 0:
			stats = GameManager.new_filter_resource(type)
	stats.type = type
	stats.globalPosition = global_position

func _process(delta):
	if stats == null:
		return
	growBacteria(delta)
	processWaste(delta)
	processNH3(delta)
	processNO2(delta)

func growBacteria(delta: float) -> void:
	var growthRate = GameManager.temperatureModifer(28.0, 10.0)
	stats.currentBacteriaBacter = minf(maxBacteria, stats.currentBacteriaBacter + (delta * stats.currentBacteriaBacter * bacteriaGrowthRate * growthRate))
	stats.currentBacteriaSomonas = minf(maxBacteria, stats.currentBacteriaSomonas + (delta * stats.currentBacteriaSomonas * bacteriaGrowthRate * growthRate))

func processWaste(delta: float) -> void:
	var amount = delta * GameManager.wasteDecayRate * 1.0
	var waste = GameManager.currentTankData.remove_waste(amount)
	var nh3Created = waste * 4
	var nh3Added = GameManager.currentTankData.add_nh3(nh3Created)
	if nh3Added < nh3Created:
		GameManager.currentTankData.add_waste(nh3Created - nh3Added)
	
func processNH3(delta: float) -> void:
	# Bacteria Somonas uses 1.5 O2 and NH3, and spits out NO2 + H+
	# Bacteria for NH3 -> NO2
	var amount = delta * GameManager.ammoniaProcessRate * stats.currentBacteriaSomonas
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
		stats.currentBacteriaSomonas = maxf(1.0, stats.currentBacteriaSomonas - ((stats.currentBacteriaSomonas * 0.05) * delta))
	GameManager.currentTankData.add_no2(no2Created)
	

func processNO2(delta: float) -> void:
	# Bacteria Bacter uses O2 and 2 x NO2, and spits out 2 NO3
	# Bacteria for NO2 -> NO3
	var amount = delta * GameManager.nitriteProcessRate * stats.currentBacteriaBacter
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
		stats.currentBacteriaBacter = maxf(1.0, stats.currentBacteriaBacter * (no3Created / amount))
	
	
func getSomonas()-> float:
	return stats.currentBacteriaSomonas

func getBacter()-> float:
	return stats.currentBacteriaBacter
