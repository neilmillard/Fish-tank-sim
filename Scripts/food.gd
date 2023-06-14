extends Area2D

@export var nutritionValue: Nutrition
@export var stats: Food
@export var type: String
@export var doesFloat: bool = true
@export var sinkTime: float = 50
@export var move_speed : float = 10
@export var rotTime: float = 4000

var sinkTimer: Timer
var rotTimer: Timer

func _ready():
	if !stats:
		stats = GameManager.new_food_resource()
	stats.type = type
	if !stats.sinking && doesFloat:
		add_sink_timer()
	else:
		start_sink()
	
	add_rot_timer()

func _physics_process(delta):
	if stats.sinking:
		# Move and Slide function uses velocity of character body to move character on map
		position += stats.move_direction * move_speed * delta
		if position.y > GameManager.currentLevelHeight - GameManager.floorHeight:
			stats.move_direction = Vector2.ZERO
		stats.globalPosition = global_position

func add_rot_timer():
	rotTimer = Timer.new()
	rotTimer.name = "rotTimer"
	add_child(rotTimer)
	rotTimer.connect("timeout", Callable(self, "_on_rot_timer_timeout"))
	rotTimer.set_wait_time(rotTime)
	rotTimer.set_one_shot(true)
	rotTimer.start()

func add_sink_timer():
	sinkTimer = Timer.new()
	sinkTimer.name = "sinkTimer"
	add_child(sinkTimer)
	sinkTimer.connect("timeout", Callable(self, "_on_sink_timer_timeout"))
	sinkTimer.set_wait_time(sinkTime)
	sinkTimer.set_one_shot(true)
	sinkTimer.start()
	
func eat():
	queue_free()
	GameManager.remove_food_resource(stats)
	return nutritionValue.duplicate()
	
func start_sink():
	stats.sinking = true
	stats.move_direction = Vector2.DOWN
	
func _on_sink_timer_timeout():
	if !stats.sinking:
		start_sink()

func _on_rot_timer_timeout():
	# TODO:
	GameManager.currentTankData.add_waste(nutritionValue.size)
	queue_free()

func _on_body_entered(body):
	if (body.has_method("eat_food")):
		body.eat_food(self)

func save():
	var save_data = {
		
	}
	return save_data
