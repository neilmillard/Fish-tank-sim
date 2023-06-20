#FishHunting
extends FishState


func enter(_msg:={}):
	fishBody.currentSwimspeed = fishBody.swimSpeed / 2.0
	fishBody.start_idle_timer(false)

func exit():
	fishBody.idleTimerRunning = false
	fishBody.idle_timer.stop()
	
func update(_delta: float) -> void:
	if fishBody.food_is_near():
		emit_signal("Transitioned", "Hunting", "Feeding")
		
func physics_update(delta: float) -> void:
	var detection = fishBody.check_environment()
	if detection == 'flee':
		emit_signal("Transitioned", "Hunting", "Fleeing")
	if detection == 'wall':
		emit_signal("Transitioned", "Hunting", "Swimming", {"direction" = Vector2.ZERO})
		
	fishBody.rotate_to_direction(Vector2(fishBody.velocity.x, 0.0), delta)

func on_idle_timer_timeout():
	var someFood = fishBody.get_nearest_food()
	var direction = Vector2.ZERO
	if someFood:
		direction = fishBody.global_position.direction_to(someFood.global_position)
	emit_signal("Transitioned", "Hunting", "Swimming", {"direction" = direction})
	fishBody.start_idle_timer(true)
