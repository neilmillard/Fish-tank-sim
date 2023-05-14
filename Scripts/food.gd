extends CharacterBody2D

@export var nutritionValue: int = 20
@export var doesFloat: bool = true
@export var sinkTime: float = 50
@export var move_speed : float = 10
@export var rotTime: float = 4000

@onready var sinkTimer = $sinkTimer
@onready var rotTimer = $rotTimer

var sinking: bool = false
var move_direction : Vector2 = Vector2.ZERO


func _ready():
	if !sinking && doesFloat:
		sinkTimer.start(sinkTime)
	else:
		start_sink()
	
	rotTimer.start(rotTime)

func _physics_process(delta):
	if sinking:
		# Move and Slide function uses velocity of character body to move character on map
		move_and_slide()

func eat():
	print("Eating food")
	queue_free()
	return nutritionValue
	
func start_sink():
	sinking = true
	move_direction = Vector2.DOWN
	velocity = move_direction * move_speed
	
func _on_sink_timer_timeout():
	print("on_sink_timout")
	if !sinking:
		print("start sinking")
		start_sink()

func _on_rot_timer_timeout():
	print("Food rotten")
	queue_free()
