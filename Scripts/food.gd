extends Area2D

@export var stats: Food
@export var myCharacter: FoodCharacter

var sinkTimer: Timer
var rotTimer: Timer

func _ready():
	$Sprite2D.texture = myCharacter.get_sprite()
	if myCharacter.animSprite:
		$Sprite2D.hframes = 3
		$AnimationPlayer.play("swim")
	if myCharacter.doesFloat and position.y < 50:
		if !stats.moving:
			add_sink_timer()
		else:
			start_move()
	if myCharacter.doesSwim:
		start_move()
	add_rot_timer()

func _physics_process(delta):
	if stats.moving:
		if myCharacter.doesSwim:
			pick_swim_direction()
		# Move and Slide function uses velocity of character body to 
		# move character on map
		position += stats.move_direction * myCharacter.move_speed * delta
		if position.y > GameManager.currentLevelHeight - GameManager.floorHeight:
			stats.move_direction.y = 0.0
		stats.globalPosition = global_position
	if sinkTimer and !sinkTimer.is_stopped():
		stats.sinkTimerDuration = sinkTimer.get_time_left()
	if rotTimer and !rotTimer.is_stopped():
		stats.rotTimerDuration = rotTimer.get_time_left()

func add_rot_timer():
	rotTimer = Timer.new()
	rotTimer.name = "rotTimer"
	add_child(rotTimer)
	rotTimer.connect("timeout", Callable(self, "_on_rot_timer_timeout"))
	rotTimer.set_wait_time(stats.rotTimerDuration)
	rotTimer.set_one_shot(true)
	rotTimer.start()

func add_sink_timer():
	sinkTimer = Timer.new()
	sinkTimer.name = "sinkTimer"
	add_child(sinkTimer)
	sinkTimer.connect("timeout", Callable(self, "_on_sink_timer_timeout"))
	sinkTimer.set_wait_time(stats.sinkTimerDuration)
	sinkTimer.set_one_shot(true)
	sinkTimer.start()
	
func eat():
	queue_free()
	GameManager.remove_food_resource(stats)
	return myCharacter.nutritionValue.duplicate()
	
func pick_swim_direction():
	var myDirection = stats.move_direction
	if myDirection == Vector2.ZERO:
		if stats.globalPosition.y < 60:
			myDirection.y = 1.0
		myDirection.x = randf_range(-0.9, 1.0)
	if stats.globalPosition.x < 50:
		if myDirection.x < 0.0:
			myDirection.x = randf_range(0.1, 1.0)
		
	if stats.globalPosition.x > GameManager.currentLevelWidth - 50:
		if myDirection.x > 0.0:
			myDirection.x = randf_range(-0.1, -1.0)
	
	if position.y > GameManager.currentLevelHeight - GameManager.floorHeight:
		myDirection.y = randf_range(-0.1, -1.0)
		
	stats.move_direction = myDirection
	
func start_move():
	stats.moving = true
	if myCharacter.doesSwim:
		pick_swim_direction()
	else:
		stats.move_direction = Vector2.DOWN
	
func _on_sink_timer_timeout():
	if !stats.moving:
		start_move()

func _on_rot_timer_timeout():
	# TODO:
	GameManager.currentTankData.add_waste(myCharacter.nutritionValue.size)
	queue_free()

func _on_body_entered(body):
	if (body.has_method("eat_food")):
		body.eat_food(self)
