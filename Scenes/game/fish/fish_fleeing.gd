#FishFleeing
extends FishState

func enter(_msg:={}):
	fishBody.currentSwimspeed = fishBody.fleeSpeed

func update(_delta: float) -> void:
	emit_signal("Transitioned", "Fleeing", "Swimming", {"direction" = Vector2.ZERO})
