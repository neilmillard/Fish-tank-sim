#Fish_Swimming
extends FishState

var direction: Vector2 = Vector2.ZERO
var previousState = ""

func enter(_msg:={}):
	if _msg.has("direction"):
		direction = _msg.direction
	previousState = _msg.previousState
	
func physics_update(_delta: float) -> void:
	if direction == Vector2.ZERO:
		while direction == Vector2.ZERO:
			direction = fishBody.get_safe_direction()
	fishBody.direction = direction
	fishBody.velocity = fishBody.direction.normalized() * fishBody.currentSwimspeed
	emit_signal("Transitioned", "Swimming", previousState)
