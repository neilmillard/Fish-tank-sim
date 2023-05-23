extends CharacterBody2D

class_name Fish

# Fish management
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var rotationSpeed = 40.0
@export var isMale: bool = true
@export var feedLevel: FeedLevel = FeedLevel.Middle
@export var sizeOfStomach: float = 100
@onready var navagent: NavigationAgent2D = $NavigationAgent
@onready var idle_timer = $IdleTimer

# State, Eating, pooing, water levels, reproduction, movement, health
enum FeedLevel {
	Top,
	Middle,
	Bottom,
}

enum FishStates {
#	Sleeping,
	Idle,
	Feeding,
	Mating,
	Fleeing,
	Swimming,
}

var myTank: TankData
var animationPlayer: AnimationPlayer

var currentState: FishStates
# Amount of hunger level, is reduced by food
var hunger: float = 0
var nearestFoodPosition: Vector2
var idleFoodDistanceThreshold: float = 400

var fishRight: bool
var fishState: String = ""
var _timer = null


func initFish(tank: TankData):
	myTank = tank

func _ready():
	animationPlayer = $AnimationPlayer
	change_state_to_idle()
	# set so we get collision events from mouse
	input_pickable = true
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", Callable(self, "_on_debug_timeout"))
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # so it loops
	_timer.start()

func _process(delta):
	# delta is in seconds
	hunger = hunger + delta
	decide_next_action()
	update_animation()
	pass

func _physics_process(delta):
	calculate_movement(delta)
	
func _on_debug_timeout():
	pass

func calculate_movement(delta):
	# Fish cannot fly out of water
	if position.y <= 5:
		velocity.y += GameManager.GRAVITY * delta
	
	# go to food
	if currentState == FishStates.Feeding:
		nav_to_food(delta)
	
	# reset floating attitude and drift
	if currentState == FishStates.Idle:
		rotate_to_direction(Vector2(velocity.x, 0), delta)
		if velocity.length() > 0:
			velocity = velocity - velocity * (0.5 * delta)
	
	# collide with walls and eat food
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().has_method("eat"):
			eat_food(collision.get_collider())

func update_animation():
	if velocity.x < 0:
		if fishRight == true:
			fishRight = false
			animationPlayer.play("SwimLeft")
			rotation_degrees = rotation_degrees * -1
	else:
		if fishRight == false:
			fishRight = true
			animationPlayer.play("SwimRight")
			rotation_degrees = rotation_degrees * -1

func rotate_to_target(target, delta):
	var direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func rotate_to_direction(direction, delta):
	var angleTo = transform.x.angle_to(direction)
	var angleDelta = sign(angleTo) * min(delta * rotationSpeed, abs(angleTo))
	if velocity.x < 0:
		rotation_degrees -= angleDelta 
	else:
		rotation_degrees += angleDelta

func decide_next_action():
	match currentState:
		FishStates.Idle:
			fishState = "Idle"
			# fish will only change from idle, if food, mate or preditor present
			if preditor_is_near():
				currentState = FishStates.Fleeing
			if hunger > 70:
				currentState = FishStates.Feeding
			if food_is_near() && hunger > 40:
				currentState = FishStates.Feeding
				
		FishStates.Feeding:
			fishState = "Feeding"
			if nearestFoodPosition == Vector2.ZERO:
				find_food()
			if nearestFoodPosition == Vector2.ZERO:
				change_state_to_idle()

		FishStates.Fleeing:
			fishState = "Fleeing"
			pass

		FishStates.Mating:
			fishState = "Mating"
			pass
	return

func change_state_to_idle():
	currentState = FishStates.Idle
	idle_timer.start(randf_range(2,6))

func nav_to_food(delta : float):
	if nearestFoodPosition:
		if navagent.is_navigation_finished():
			reset_food_finder()
			return
		else:
			# if we are nearly at the destination (food) let's check if it moved
			if navagent.distance_to_target() < swimSpeed:
				find_food()
			var targetpos = navagent.get_next_path_position()
			if (targetpos == null):
				print("Cannot get to food")
				reset_food_finder()
				return
			var direction = global_position.direction_to(targetpos)
			if direction != Vector2.ZERO:
				rotate_to_direction(direction, delta)
				velocity = direction * swimSpeed

func find_food():
	if food_is_near():
		nearestFoodPosition = get_nearest_food().global_position
		if nearestFoodPosition != Vector2.ZERO:
			navagent.set_target_position(nearestFoodPosition)
	else:
		var someFood = get_nearest_food()
		if someFood:
			var direction = global_position.direction_to(someFood.global_position)
			if direction != Vector2.ZERO:
				velocity = direction * swimSpeed
				change_state_to_idle()
		else:
			change_state_to_idle()
	return

func reset_food_finder():
	nearestFoodPosition = Vector2.ZERO
	change_state_to_idle()

func eat_food(foodObject):
	if foodObject:
		# hunger can go negative, equiv to the fish storing food in belly
		if hunger + sizeOfStomach > foodObject.nutritionValue:
			hunger = hunger - foodObject.eat()

func get_nearest_food():
	var resources = get_tree().get_nodes_in_group("food")
	if resources.is_empty():
		# No food found
		return null
	var food = resources[0]
	for i in resources:
		if i.position.distance_to(position) < food.position.distance_to(position):
			food = i
	return food

func preditor_is_near():
	return false

func food_is_near():
	var food = get_nearest_food()
	if food:
		if food.position.distance_to(position) < idleFoodDistanceThreshold:
			return true
	return false

func pick_idle_direction():
	var direction = Vector2(randi_range(-1,1),randi_range(-1,1))
	velocity = direction.normalized() * (swimSpeed / 2.0)

func _on_idle_timer_timeout():
	if currentState == FishStates.Idle:
		pick_idle_direction()
		change_state_to_idle()

# The mouse is hovering over us
func _on_mouse_entered():
	GameManager.set_fish(self)
	

# The mouse is no longer hovering over us
func _on_mouse_exited():
	GameManager.clear_fish()
