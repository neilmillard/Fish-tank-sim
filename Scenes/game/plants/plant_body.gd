class_name PlantBody
extends Node2D

@export var stats: Plant

# This plant scene stats
@export var type: String = "Generic"
@export var maxHealth: float = 100
@export var maxGrowStage: float = 3
@export var processingRate: float = 1
@export var growthThreshold: float = 1000.0
@export var growthCost: float = 500.0
@export var livingCost: float = 0.01

@onready var label = $Label
@onready var sprite2D = $Sprite2D
@onready var fsm = $StateMachine

func _ready():
	if !stats:
		if type.length() > 0:
			stats = GameManager.new_plant_resource(type)
		else:
			stats = GameManager.new_plant_resource()
	stats.type = type
	stats.globalPosition = global_position
	sprite2D.frame = stats.growStage

func _process(delta):
	if fsm && fsm.currentState:
		label.text = fsm.currentState.name
	# TODO: effect water chemistry
	process_health(delta)


func _physics_process(_delta):
	pass


func process_health(delta: float) -> void:
	# the plant consumes it's own sugar for sustenance
	var cost = delta * livingCost * (stats.growStage+1)
	if stats.storedSugar > cost:
		stats.storedSugar -= cost
	else:
		stats.currentHealth = stats.currentHealth - (cost - stats.storedSugar)
		stats.storedSugar = 0.0
	
	if stats.currentHealth < maxHealth and stats.storedSugar > 0:
		if maxHealth - stats.currentHealth < 1:
			cost = cost * (maxHealth - stats.currentHealth)
		if stats.storedSugar > cost:
			stats.storedSugar -= cost
			stats.currentHealth += cost
		
	if stats.currentHealth > maxHealth:
		stats.currentHealth = maxHealth
