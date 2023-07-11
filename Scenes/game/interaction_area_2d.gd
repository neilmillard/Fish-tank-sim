class_name InteractionArea extends Area2D

const BASERADIUS = 40.0
const BASEHEIGHT = 120.0
const BASEROTATION = 90.0

@onready var collShape : CollisionShape2D = $CollisionShape2D
@onready var myShape : CapsuleShape2D

var parentNode
var bodies = []

func _ready():
	myShape = collShape.get_shape()
	collShape.rotation_degrees = BASEROTATION
	

func set_size(size: float) -> void:
	myShape.radius = size * BASERADIUS
	myShape.height = size * BASEHEIGHT

func _on_body_entered(body):
	if body == parentNode:
		return
	bodies.insert(0, body)

func _on_body_exited(body):
	bodies.erase(body)
