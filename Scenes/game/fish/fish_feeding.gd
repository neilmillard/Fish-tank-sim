#FishFeeding
extends FishState

func enter(_msg:={}):
	fishBody.currentSwimspeed = fishBody.swimSpeed

func update(_delta: float) -> void:
	if fishBody.nearestFoodPosition == Vector2.ZERO:
		fishBody.find_food()
	
	if fishBody.nearestFoodPosition == Vector2.ZERO:
		emit_signal("Transitioned", "Feeding", "Hunting")

func physics_update(delta: float) -> void:
	if fishBody.nearestFoodPosition != Vector2.ZERO:
		if fishBody.navagent.is_navigation_finished():
			reset_food_finder()
			return
		else:
			# if we are nearly at the destination (food) let's check if it moved
			if fishBody.navagent.distance_to_target() < fishBody.swimSpeed:
				fishBody.find_food()
			var targetpos = fishBody.navagent.get_next_path_position()
			if (targetpos == null):
				print("Cannot get to food")
				reset_food_finder()
				return
			fishBody.direction = fishBody.global_position.direction_to(targetpos)
			fishBody.rotate_to_direction(fishBody.direction, delta)
			fishBody.velocity = fishBody.direction.normalized() * fishBody.currentSwimspeed
	
func reset_food_finder() -> void:
	fishBody.nearestFoodPosition = Vector2.ZERO
	emit_signal("Transitioned", "Feeding", "Idle")
