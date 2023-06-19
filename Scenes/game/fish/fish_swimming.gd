#Fish_Swimming
extends FishState

var direction: Vector2 = Vector2.ZERO

func enter(_msg:={}):
	if _msg.has("direction"):
		direction = _msg.direction
	
func physics_update(_delta: float) -> void:
	if direction == Vector2.ZERO:
		direction = Vector2(randi_range(-1,1),randi_range(-1,1))
	fishBody.direction = direction
	fishBody.velocity = fishBody.direction.normalized() * fishBody.currentSwimspeed
	emit_signal("Transitioned", "Swimming", "Idle")
