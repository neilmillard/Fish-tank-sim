#FishDead
extends FishState

var timer: float

func enter(_msg:={}):
	fishBody.currentSwimspeed = 0
	fishBody.velocity = Vector2.ZERO
	fishBody.animationPlayer.play("SwimLeft")
	fishBody.animationPlayer.stop()
	timer = 0.0

func exit():
	pass
	
func update(delta: float) -> void:
	timer += delta
	if timer > 20.0:
		var myNutrition = fishBody.myStomach.release_food()
		if myNutrition != null:
			GameManager.spawn_food(fishBody.position, myNutrition)
			timer = 0.0
		else:
			print(fishBody.name + " Time to die")
			fishBody.kill_fish()
			
func physics_update(delta: float) -> void:
	fishBody.rotate_to_direction(Vector2(-1.0, 0.0), delta)
	
