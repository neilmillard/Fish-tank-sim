#FishIdle
extends FishState

func enter(_msg:={}):
	myBody.start_idle_timer(true)
	myBody.currentSwimspeed = myBody.swimSpeed / 4.0
	

func exit():
	myBody.idleTimerRunning = false
	myBody.idle_timer.stop()

func update(_delta: float) -> void:
	if myBody.stats.currentHealth <= 0:
		emit_signal("Transitioned", "Idle", "Dead")
		return
	# fish will only change from idle, if food, mate or preditor present
	if myBody.myStomach.could_eat():
		if myBody.food_is_near():
			emit_signal("Transitioned", "Idle", "Feeding")
			return
		else:
			emit_signal("Transitioned", "Idle", "Hunting")
			return
#	if myBody.myStomach.storedEnergy > 100.0:
#		emit_signal("Transitioned", "Idle", "Mating")
	
func on_idle_timer_timeout():
	emit_signal("Transitioned", "Idle", "Swimming", 
				{"direction" = Vector2.ZERO, "previousState" = "Idle"})
	myBody.start_idle_timer(true)


func physics_update(delta: float) -> void:
	myBody.rotate_to_direction(Vector2(myBody.velocity.x, 0.0), delta)
	if check_preditors() == 'flee':
		emit_signal("Transitioned", "Idle", "Fleeing", {"previousState" = "Idle"})
		return
