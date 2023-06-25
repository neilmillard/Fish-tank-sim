extends Node2D

@export var stats: Plant

# This fish scene stats
@export var type: String = "Generic"
@export var maxHealth: float = 100
@export var maxGrowStage: float = 3

@onready var label = $Label
@onready var fsm = $StateMachine

func _ready():
	if !stats:
		if type.length() > 0:
			stats = GameManager.new_plant_resource(type)
		else:
			stats = GameManager.new_plant_resource()
	stats.type = type
	stats.globalPosition = global_position
