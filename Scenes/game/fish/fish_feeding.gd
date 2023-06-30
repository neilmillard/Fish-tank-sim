#FishFeeding
extends FishState

func enter(_msg:={}):
	myBody.currentSwimspeed = myBody.swimSpeed

func update(_delta: float) -> void:
	if myBody.nearestFoodPosition == Vector2.ZERO:
		myBody.find_food()
	
	if myBody.nearestFoodPosition == Vector2.ZERO:
		emit_signal("Transitioned", "Feeding", "Idle")

func physics_update(delta: float) -> void:
	if myBody.nearestFoodPosition != Vector2.ZERO:
		if myBody.navagent.is_navigation_finished():
			reset_food_finder()
			return
		else:
			# if we are nearly at the destination (food) let's check if it moved
			if myBody.navagent.distance_to_target() < myBody.swimSpeed:
				myBody.find_food()
			var targetpos = myBody.navagent.get_next_path_position()
			if (targetpos == null):
				print("Cannot get to food")
				reset_food_finder()
				return
			myBody.direction = myBody.global_position.direction_to(targetpos)
			myBody.rotate_to_direction(myBody.direction, delta)
			myBody.velocity = myBody.direction.normalized() * myBody.currentSwimspeed
	
func reset_food_finder() -> void:
	myBody.nearestFoodPosition = Vector2.ZERO
	emit_signal("Transitioned", "Feeding", "Idle")
