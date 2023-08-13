#FishFleeing
extends FishState

var fleeDirection: Vector2 = Vector2.ZERO
var previousState
var triggeredTimer

func enter(_msg:={}):
	previousState = _msg.previousState
	if previousState == "Swimming":
		previousState = "Idle"
	triggeredTimer = 0.4
	fleeDirection = myBody.get_safe_direction()
	set_fish_velocity()

func update(delta: float) -> void:
	triggeredTimer -= delta

func physics_update(delta: float) -> void:
	myBody.rotate_to_direction(myBody.direction, delta)
	var detection = myBody.check_environment()
	if detection != 'flee' and triggeredTimer < 0.0:
		emit_signal("Transitioned", "Fleeing", previousState)
		return
		
	if myBody.velocity.length_squared() < 5:
		fleeDirection = myBody.get_safe_direction()
	
	set_fish_velocity()

func set_fish_velocity():
	myBody.direction = fleeDirection
	myBody.velocity = myBody.direction.normalized() * myBody.myCharacter.fleeSpeed
