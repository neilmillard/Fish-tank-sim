#FishDead
extends FishState

var timer: float

func enter(_msg:={}):
	myBody.currentSwimspeed = 0
	myBody.velocity = Vector2.DOWN * 10.0
	myBody.animationPlayer.play("SwimLeft")
	myBody.animationPlayer.stop()
	timer = 0.0

func exit():
	pass
	
func update(delta: float) -> void:
	timer += delta
	if timer > 20.0:
		var myNutrition = myBody.myStomach.release_food()
		if myNutrition != null:
			GameManager.spawn_fishfood(myBody.position, myNutrition)
			timer = 0.0
		else:
			myBody.kill_fish()
			
func physics_update(delta: float) -> void:
	myBody.rotate_to_direction(Vector2(-1.0, 0.0), delta)
	
