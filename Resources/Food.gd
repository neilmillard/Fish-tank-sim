class_name Food
extends Resource

@export var id: int
@export var globalPosition: Vector2
@export var type: String
@export var moving: bool
@export var move_direction: Vector2
@export var sinkTimerDuration: float
@export var rotTimerDuration: float

func _init(	p_type: String = "FlakeFood",
			p_globalPos: Vector2 = Vector2.ZERO, 
			p_moving: bool = false, 
			p_move_direction: Vector2 = Vector2.ZERO,
			p_sinkTime: float= 0.0,
			p_rotTime: float = 0.0):
	id = randi() % 1000000
	type = p_type
	moving = p_moving
	move_direction = p_move_direction
	sinkTimerDuration = p_sinkTime
	rotTimerDuration = p_rotTime
	globalPosition = p_globalPos
