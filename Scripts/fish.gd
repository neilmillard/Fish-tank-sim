extends CharacterBody2D

class_name Fish

# Fish management
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var rotationSpeed = 40.0
@export var isMale: bool = true
@export var feedLevel: FeedLevel = FeedLevel.Middle

@onready var myStomach: Stomach = $Stomach
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
	Hunting,
	Mating,
	Fleeing,
}

var animationPlayer: AnimationPlayer

var currentState: FishStates
# Amount of hunger level, is reduced by food

var nearestFoodPosition: Vector2
var idleFoodDistanceThreshold: float = 400
var idleTimerRunning: bool = false
var oldVelocity: Vector2

var fishRight: bool
var fishState: String = ""
var _timer = null


func _ready():
	animationPlayer = $AnimationPlayer
	start_idle_timer()
	# set so we get collision events from mouse
	input_pickable = true
	add_debug_timer()

func _process(delta):
	# delta is in seconds
	decide_next_action()
	update_animation()
	# TODO: effect water chemistry when processing waste
	# process_waste(delta)
	pass

func _physics_process(delta):
	calculate_movement(delta)
	
func _on_debug_timeout():
	pass

func calculate_movement(delta):
	# Fish cannot fly out of water
	if position.y <= 28:
		velocity.y += GameManager.GRAVITY * delta
	
	# go to food
	if currentState == FishStates.Feeding:
		nav_to_food(delta)
	
	# reset floating attitude and drift
	if currentState == FishStates.Idle or nearestFoodPosition == Vector2.ZERO:
		rotate_to_direction(Vector2(velocity.x, 0), delta)
		
	# collide with walls and eat food
	var collision = use_muscle_energy(delta)
	if collision:
		if collision.get_collider().has_method("eat"):
			eat_food(collision.get_collider())
	
	if velocity.length() > 0:
		velocity = velocity - velocity * (0.5 * delta)
	

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

func use_muscle_energy(delta: float) -> KinematicCollision2D:
	# energy is needed to accelerate
	var velocityDiff =  velocity.length_squared() - oldVelocity.length_squared()
	if velocityDiff > 0:
		var energyRequired = (velocityDiff / swimSpeed) * delta
		var energyUsed = myStomach.get_energy(energyRequired)
		if energyRequired > energyUsed:
			velocity = oldVelocity
			
	oldVelocity = velocity
	var collision = move_and_collide(velocity * delta)
	return collision
	
func process_waste(delta: float) -> void:
	# lets get rid of waste if we are moving
	if(abs(velocity.x)) > swimSpeed / 4:
		myStomach.flush_waste(0.1 * delta)

func rotate_to_target(target, delta):
	var direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func rotate_to_direction(direction: Vector2, delta: float) -> void:
	var angleTo = transform.x.angle_to(direction)
	var angleDelta = sign(angleTo) * min(delta * rotationSpeed, abs(angleTo))
	if velocity.x < 0:
		rotation_degrees -= angleDelta 
	else:
		rotation_degrees += angleDelta

func change_fish_state(state: FishStates):
	if currentState != state:
		idleTimerRunning = false
		idle_timer.stop()
	
	if state == FishStates.Idle:	
		start_idle_timer()
	
	currentState = state

func decide_next_action():
	if currentState == FishStates.Idle:
		fishState = "Idle"
		# fish will only change from idle, if food, mate or preditor present
		if preditor_is_near():
			change_fish_state(FishStates.Fleeing)
		if myStomach.storedEnergy < myStomach.capacity && myStomach.could_eat():
			if food_is_near():
				change_fish_state(FishStates.Feeding)
			else:
				change_fish_state(FishStates.Hunting)
		if food_is_near() && myStomach.could_eat():
			change_fish_state(FishStates.Feeding)
				
	if currentState == FishStates.Feeding:
		fishState = "Feeding"
		if nearestFoodPosition == Vector2.ZERO:
			find_food()
		if nearestFoodPosition == Vector2.ZERO:
			change_fish_state(FishStates.Idle)

	if currentState == FishStates.Hunting:
		fishState = "Hunting"
		if food_is_near():
			change_fish_state(FishStates.Feeding)
		if !idleTimerRunning:
			start_idle_timer()
		pass
		
	if currentState == FishStates.Fleeing:
		fishState = "Fleeing"
		pass

	if currentState == FishStates.Mating:
		fishState = "Mating"
		pass
	return

func start_idle_timer():
	if !idleTimerRunning:
		idleTimerRunning = true
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
	if !idleTimerRunning:
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
			if currentState != FishStates.Hunting:
				change_fish_state(FishStates.Hunting)
	return

func reset_food_finder():
	nearestFoodPosition = Vector2.ZERO
	if idleTimerRunning == false:
		change_fish_state(FishStates.Idle)

func eat_food(foodObject: Food):
	if foodObject:
		# hunger can go negative, equiv to the fish storing food in belly
		if myStomach.has_space_to_eat(foodObject.nutritionValue.size):
			myStomach.receive_food(foodObject.eat())
		nearestFoodPosition = Vector2.ZERO

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
	idleTimerRunning = false
	if currentState == FishStates.Idle:
		pick_idle_direction()
		start_idle_timer()
	if currentState == FishStates.Hunting:
		find_food()
		start_idle_timer()
		

# The mouse is hovering over us
func _on_mouse_entered():
	GameManager.set_fish(self)
	

# The mouse is no longer hovering over us
func _on_mouse_exited():
	GameManager.clear_fish()

func add_debug_timer():
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", Callable(self, "_on_debug_timeout"))
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # so it loops
	_timer.start()
