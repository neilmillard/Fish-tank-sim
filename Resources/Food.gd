class_name Food
extends Resource

@export var id: int
@export var globalPosition: Vector2
@export var type: String
@export var sinking: bool
@export var move_direction: Vector2

@export var sinkTimerDuration: float
@export var rotTimerDuration: float

func _init():
	id = randi() % 1000000
	sinking = false
	move_direction = Vector2.ZERO
	
