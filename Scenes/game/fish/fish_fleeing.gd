#FishFleeing
extends FishState

var fleeDirection: Vector2 = Vector2.ZERO
var previousState

func enter(_msg:={}):
	previousState = _msg.previousState
	while fleeDirection == Vector2.ZERO:
		fleeDirection = Vector2(
			randi_range(fishBody.avoidLeft,fishBody.avoidRight),
			randi_range(fishBody.avoidUp,fishBody.avoidDown)
			)
	set_fish_velocity()

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	var detection = fishBody.check_environment()
	if detection != 'flee':
		emit_signal("Transitioned", "Fleeing", previousState)
		return
	set_fish_velocity()

func set_fish_velocity():
	fishBody.direction = fleeDirection
	fishBody.velocity = fishBody.direction.normalized() * fishBody.fleeSpeed
