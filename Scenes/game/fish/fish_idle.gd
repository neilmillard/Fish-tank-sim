#FishIdle
extends FishState

func enter(_msg:={}):
	fishBody.start_idle_timer(true)
	

func exit():
	fishBody.idleTimerRunning = false
	fishBody.idle_timer.stop()

func update(_delta: float) -> void:
	fishBody.currentSwimspeed = fishBody.swimSpeed / 4.0
	# fish will only change from idle, if food, mate or preditor present
	if fishBody.preditor_is_near():
		emit_signal("Transitioned", "idle", "fleeing")
		# fishBody.change_fish_state(FishStates.Fleeing)
	if fishBody.myStomach.could_eat():
		if fishBody.food_is_near():
			emit_signal("Transitioned", "Idle", "Feeding")
		else:
			emit_signal("Transitioned", "Idle", "Hunting")
	if fishBody.food_is_near() && fishBody.myStomach.could_eat():
		emit_signal("Transitioned", "Idle", "Feeding")
	
func on_idle_timer_timeout():
	emit_signal("Transitioned", "Idle", "Swimming", {"direction" = Vector2.ZERO})
	fishBody.start_idle_timer(true)


func physics_update(delta: float) -> void:
	var detection = fishBody.check_environment()
	if detection == 'flee':
		emit_signal("Transitioned", "Idle", "Fleeing")
	if detection == 'wall':
		fishBody.velocity = Vector2.ZERO
	fishBody.rotate_to_direction(Vector2(fishBody.velocity.x, 0.0), delta)
	
