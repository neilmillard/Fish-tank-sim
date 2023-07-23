#FishHunting
extends FishState


func enter(_msg:={}):
	myBody.currentSwimspeed = myBody.get_current_swimSpeed() / 2.0
	myBody.start_idle_timer(false)

func exit():
	myBody.idleTimerRunning = false
	myBody.idle_timer.stop()
	
func update(_delta: float) -> void:
	if myBody.stats.currentHealth <= 0:
		emit_signal("Transitioned", "Hunting", "Dead")
		return
	if myBody.food_is_near():
		emit_signal("Transitioned", "Hunting", "Feeding")
		return
	if !myBody.myStomach.could_eat():
		emit_signal("Transitioned", "Hunting", "Idle")
		return
		
func physics_update(delta: float) -> void:
	myBody.rotate_to_direction(Vector2(myBody.velocity.x, 0.0), delta)
	if check_preditors() == 'flee':
		emit_signal("Transitioned", "Hunting", "Fleeing", {"previousState" = "Hunting"})
		return

func on_idle_timer_timeout():
	var someFood = myBody.get_nearest_food(myBody.global_position)
	var direction = Vector2.ZERO
	if someFood:
		direction = myBody.global_position.direction_to(someFood.global_position)
	emit_signal("Transitioned", "Hunting", "Swimming", {"direction" = direction, "previousState" = "Hunting"})
	myBody.start_idle_timer(true)
