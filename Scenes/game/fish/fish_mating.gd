#FishMating
extends FishState

var matingTimer : float = 0.0
var matingTimeout : float = 100.0

func enter(_msg:={}):
	myBody.start_idle_timer(true)
	myBody.currentSwimspeed = myBody.get_current_swimSpeed() / 2.0
	matingTimer = 0.0

func exit():
	myBody.idleTimerRunning = false
	myBody.idle_timer.stop()

func update(delta: float) -> void:
	if !myBody.over_mating_threshold() || matingTimer > matingTimeout:
		emit_signal("Transitioned", "Mating", "Idle")		
	matingTimer += delta

func physics_update(delta: float) -> void:
	myBody.rotate_to_direction(Vector2(myBody.velocity.x, 0.0), delta)
	var preditorCheck = check_preditors()
	if preditorCheck == 'flee':
		emit_signal("Transitioned", "Mating", "Fleeing", {"previousState" = "Mating"})
		return
	myBody.mate()
		
func on_idle_timer_timeout():
	var someMate = get_nearest_mate()
	var direction = Vector2.ZERO
	if myBody.stats.isMale && someMate:
		direction = myBody.global_position.direction_to(someMate.globalPosition)
	emit_signal("Transitioned", "Mating", "Swimming", 
				{"direction" = direction, "previousState" = "Mating"})
	
	myBody.start_idle_timer(true)

func get_nearest_mate() -> Fish:
	var mates = myBody.get_nearest_mates(400.0)
	if mates.is_empty():
		return null
	var mate = mates[0]
	for i in mates:
		if i.globalPosition.distance_to(myBody.position) < mate.globalPosition.distance_to(myBody.position):
			mate = i
	return mate
