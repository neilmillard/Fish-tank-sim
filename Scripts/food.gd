extends Area2D
class_name Food

@export var nutritionValue: Nutrition
@export var doesFloat: bool = true
@export var sinkTime: float = 50
@export var move_speed : float = 10
@export var rotTime: float = 4000

@onready var sinkTimer = $sinkTimer
@onready var rotTimer = $rotTimer

var sinking: bool = false
var finder: Fish = null
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
		position += move_direction * move_speed * delta
		if position.y > GameManager.floor:
			move_direction = Vector2.ZERO

func eat():
	queue_free()
	return nutritionValue.duplicate()
	
func start_sink():
	sinking = true
	move_direction = Vector2.DOWN
	
func _on_sink_timer_timeout():
	if !sinking:
		start_sink()

func _on_rot_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if (body.has_method("eat_food")):
		body.eat_food(self)
