extends CharacterBody2D

class_name Fish

# Fish management
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var rotationSpeed = 40.0
@export var isMale: bool = true
@export var feedLevel: FeedLevel = FeedLevel.Middle
@export var maxHealth: float = 100

@onready var myStomach: Stomach = $Stomach
@onready var myLung: Lung = $Lung
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
	Swimming,
	Feeding,
	Hunting,
	Mating,
	Fleeing,
}

var fishSize: float = 1.0
var animationPlayer: AnimationPlayer
var fishFaceRight: bool
var fishState: String = ""
var currentState: FishStates
var currentHealth: float = 95.0
var currentSwimspeed: float

var nearestFoodPosition: Vector2
var idleFoodDistanceThreshold: float = 400
var idleTimerRunning: bool = false
var direction: Vector2
var oldVelocity: Vector2
var swimTime: float

var _timer = null


func _ready():
	animationPlayer = $AnimationPlayer
	start_idle_timer(true)
	# set so we get collision events from mouse
	input_pickable = true
	currentSwimspeed = swimSpeed
	add_debug_timer()
	GameManager.stats.add_property(self, "currentHealth", "round")
	GameManager.stats.add_property(self, "nearestFoodPosition", "")
	GameManager.stats.add_property(self, "currentSwimspeed", "round")
	GameManager.stats.add_property(self, "velocity", "")

func _process(delta):
	# delta is in seconds
	decide_next_action(delta)
	# TODO: effect water chemistry when processing waste
	process_waste(delta)
	process_health(delta)


func _physics_process(delta):
	calculate_movement(delta)
	update_animation()
	
func _on_debug_timeout():
	pass

func process_health(delta: float) -> void:
	# The fish will expend energy on fighting infection
	if currentHealth < maxHealth:
		var energyRequired = delta * GameManager.infectionEnergy
		var energyReceived = myStomach.get_energy(energyRequired)
		var o2Used = myLung.requestO2(energyReceived)
		myStomach.receive_nh3(energyReceived / 4.0)
		if energyReceived == energyRequired and o2Used == energyReceived:
			currentHealth += delta
	if currentHealth > maxHealth:
		currentHealth == maxHealth
	
	# poor water quality will assist the growing infection
	if GameManager.currentTankData.currentNH3 > GameManager.nh3HealthThreshold:
		currentHealth -= delta / 2.0
	
	if currentHealth == 0:
		# Fish is fish food
		myStomach.release_food()
		GameManager.spawn_dead_fish()
		queue_free()

func calculate_movement(delta):
	# Water friction init
	if velocity.length() > 0:
		velocity = velocity - (velocity * GameManager.waterFriction * delta)
	# stash for energy calculation
	oldVelocity = velocity
	
	# go to food
	if currentState == FishStates.Feeding:
		nav_to_food(delta)
	
	# apply some thrust
	if (direction != Vector2.ZERO && 
		currentState != FishStates.Idle && 
		currentState != FishStates.Hunting):
		velocity = direction.normalized() * currentSwimspeed
		
	# Fish cannot fly out of water
	if position.y <= 28:
		velocity.y += GameManager.GRAVITY * delta

	rotate_to_direction(direction, delta)
	use_muscle_energy(delta)
	
	# collide with walls and eat food
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().has_method("eat"):
			eat_food(collision.get_collider())


func use_muscle_energy(delta: float) -> void:
	# energy is needed to accelerate
	var velocityDiff =  velocity.length_squared() - oldVelocity.length_squared()
	if velocityDiff > 0:
		var energyRequired = (velocityDiff / swimSpeed) * delta * fishSize
		var energyReceived = myStomach.get_energy(energyRequired)
		var o2Used = myLung.requestO2(energyReceived)
		# stash waste in the stomach (well sorta kidneys bladder)
		myStomach.receive_nh3(energyReceived / 4.0)
		if energyReceived < energyRequired:
			if oldVelocity.length_squared() > 2:
				velocity = oldVelocity
		else:
			if o2Used < energyReceived:
				currentHealth -= delta

func update_animation():
	if velocity.x < 0:
		if fishFaceRight == true:
			fishFaceRight = false
			animationPlayer.play("SwimLeft")
			rotation_degrees = rotation_degrees * -1
	else:
		if fishFaceRight == false:
			fishFaceRight = true
			animationPlayer.play("SwimRight")
			rotation_degrees = rotation_degrees * -1

func process_waste(delta: float) -> void:
	# lets get rid of waste if we are moving
	if(abs(velocity.x)) > swimSpeed / 4.0:
		GameManager.currentTankData.add_waste(myStomach.flush_waste(1.0 * delta))
		GameManager.currentTankData.add_nh3(myStomach.flush_nh3(1.0 * delta))
		
func rotate_to_target(target, delta):
	var direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func rotate_to_direction(direction: Vector2, delta: float) -> void:
	if velocity == Vector2.ZERO:
		return
	
	var angleTo = transform.x.angle_to(direction)
	
	# reset floating attitude and drift
	if currentState == FishStates.Idle or currentState == FishStates.Hunting:
		angleTo = transform.x.angle_to(Vector2(velocity.x, 0.0))
	
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
		start_idle_timer(true)
	
	if state == FishStates.Swimming:
		swimTime = 0.0
	
	currentState = state

func decide_next_action(delta):	
	if currentState == FishStates.Idle:
		fishState = "Idle"
		currentSwimspeed = swimSpeed / 4.0	
		# fish will only change from idle, if food, mate or preditor present
		if preditor_is_near():
			change_fish_state(FishStates.Fleeing)
		if myStomach.could_eat():
			if food_is_near():
				change_fish_state(FishStates.Feeding)
			else:
				change_fish_state(FishStates.Hunting)
		if food_is_near() && myStomach.could_eat():
			change_fish_state(FishStates.Feeding)
	
	if currentState == FishStates.Swimming:
		fishState = "Swimming"
		if swimTime > 0.05:
			change_fish_state(FishStates.Idle)
		swimTime += delta
		
	if currentState == FishStates.Feeding:
		currentSwimspeed = swimSpeed
		fishState = "Feeding"
		if nearestFoodPosition == Vector2.ZERO:
			find_food()
		if nearestFoodPosition == Vector2.ZERO:
			change_fish_state(FishStates.Idle)

	if currentState == FishStates.Hunting:
		currentSwimspeed = swimSpeed / 2.0
		fishState = "Hunting"
		if food_is_near():
			change_fish_state(FishStates.Feeding)
		if !idleTimerRunning:
			start_idle_timer(false)
		pass
		
	if currentState == FishStates.Fleeing:
		currentSwimspeed = fleeSpeed
		fishState = "Fleeing"
		pass

	if currentState == FishStates.Mating:
		currentSwimspeed = swimSpeed / 2.0
		fishState = "Mating"
		pass
	return

func start_idle_timer(shorter: bool = true):
	if !idleTimerRunning:
		idleTimerRunning = true
		var maxWait = 6.0
		if shorter:
			maxWait = 6.0	
		idle_timer.start(randf_range(3.0,maxWait))


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
			direction = global_position.direction_to(targetpos)

func find_food():
	if !idleTimerRunning:
		if food_is_near():
			nearestFoodPosition = get_nearest_food().global_position
			if nearestFoodPosition != Vector2.ZERO:
				navagent.set_target_position(nearestFoodPosition)
		else:
			var someFood = get_nearest_food()
			if someFood:
				direction = global_position.direction_to(someFood.global_position)
			else:
				direction = Vector2.ZERO
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
	direction = Vector2(randi_range(-1,1),randi_range(-1,1))
	change_fish_state(FishStates.Swimming)

func _on_idle_timer_timeout():
	idleTimerRunning = false
	if currentState == FishStates.Idle:
		pick_idle_direction()
		start_idle_timer(true)
	if currentState == FishStates.Hunting:
		find_food()
		change_fish_state(FishStates.Swimming)
		start_idle_timer(false)
		

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
