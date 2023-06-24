#FishFleeing
extends FishState

var fleeDirection: Vector2 = Vector2.ZERO
var previousState
var triggeredTimer

func enter(_msg:={}):
	previousState = _msg.previousState
	triggeredTimer = 0.6
	while fleeDirection == Vector2.ZERO:
		fleeDirection = fishBody.get_safe_direction()
	set_fish_velocity()

func update(delta: float) -> void:
	triggeredTimer -= delta
	fishBody.rotate_to_direction(fishBody.direction, delta)

func physics_update(_delta: float) -> void:
	var detection = fishBody.check_environment()
	if detection != 'flee' and triggeredTimer < 0.0:
		emit_signal("Transitioned", "Fleeing", previousState)
		return
		
	if fishBody.velocity.length_squared() < 5:
		fleeDirection = fishBody.get_safe_direction()
	
	set_fish_velocity()

func set_fish_velocity():
	fishBody.direction = fleeDirection
	fishBody.velocity = fishBody.direction.normalized() * fishBody.fleeSpeed
