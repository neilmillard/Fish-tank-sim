#FishIdle
extends FishState

func enter(_msg:={}):
	fishBody.start_idle_timer(true)
	fishBody.currentSwimspeed = fishBody.swimSpeed / 4.0
	

func exit():
	fishBody.idleTimerRunning = false
	fishBody.idle_timer.stop()

func update(_delta: float) -> void:
	# fish will only change from idle, if food, mate or preditor present
	check_preditors("Idle")
	if fishBody.myStomach.could_eat():
		if fishBody.food_is_near():
			emit_signal("Transitioned", "Idle", "Feeding")
		else:
			emit_signal("Transitioned", "Idle", "Hunting")
	if fishBody.food_is_near() && fishBody.myStomach.could_eat():
		emit_signal("Transitioned", "Idle", "Feeding")
	
func on_idle_timer_timeout():
	emit_signal("Transitioned", "Idle", "Swimming", 
				{"direction" = Vector2.ZERO, "previousState" = "Idle"})
	fishBody.start_idle_timer(true)


func physics_update(delta: float) -> void:
	fishBody.rotate_to_direction(Vector2(fishBody.velocity.x, 0.0), delta)
	
