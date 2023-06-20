#Fish_Swimming
extends FishState

var direction: Vector2 = Vector2.ZERO

func enter(_msg:={}):
	if _msg.has("direction"):
		direction = _msg.direction
	
func physics_update(_delta: float) -> void:
	if direction == Vector2.ZERO:
		direction = Vector2(
			randi_range(fishBody.avoidLeft,fishBody.avoidRight),
			randi_range(fishBody.avoidUp,fishBody.avoidDown)
			)
	fishBody.direction = direction
	fishBody.velocity = fishBody.direction.normalized() * fishBody.currentSwimspeed
	emit_signal("Transitioned", "Swimming", "Idle")
