extends CharacterBody2D
class_name FishBody

enum FeedLevel {
	Top,
	Middle,
	Bottom,
}

# State, Eating, pooing, water levels, reproduction, movement, health
enum FishStates {
#	Sleeping,
	Idle,
	Swimming,
	Feeding,
	Hunting,
	Mating,
	Fleeing,
}

@export var stats: Fish
@export var myStomach: Stomach
@export var myLung: Lung

# This fish scene stats
@export var type: String = "Generic"
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var rotationSpeed = 40.0
@export var feedLevel: FeedLevel = FeedLevel.Middle
@export var maxHealth: float = 100
@export var idleFoodDistanceThreshold: float = 400

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var navagent: NavigationAgent2D = $NavigationAgent
@onready var label = $Label
@onready var fsm = $StateMachine

@onready var idle_timer = $IdleTimer
var fishFaceRight: bool
var fishState: String = ""
var currentState: FishStates
var currentSwimspeed: float
var nearestFoodPosition: Vector2
var idleTimerRunning: bool = false
var direction: Vector2
var oldVelocity: Vector2
var swimTime: float
var idleTime: float
var avoidUp: int
var avoidDown: int
var avoidLeft: int
var avoidRight: int

var _timer = null


func _ready():
	if !stats:
		stats = GameManager.new_fish_resource()
	stats.type = type
	myStomach = stats.myStomach
	myLung = stats.myLung
	# set so we get collision events from mouse
	input_pickable = true
	currentSwimspeed = swimSpeed
	fishFaceRight = true
	animationPlayer.play("SwimRight")
	add_debug_timer()

func _process(delta):
	if fsm && fsm.currentState:
		label.text = fsm.currentState.name
	# TODO: effect water chemistry when processing waste
	process_lung(delta)
	process_food(delta)
	process_waste(delta)
	process_health(delta)


func _physics_process(delta):
	calculate_movement(delta)
	update_animation()
	
func _on_debug_timeout():
	pass

func is_foe(result) -> bool:
	return result.collider.collision_layer && result.collider.collision_layer != 1

func is_wall(result) -> bool:
	return result.collider.collision_layer && result.collider.collision_layer == 1

func check_raycast_result(result, new_result) -> Dictionary:
	new_result = {
		'move': 1,
	}
	if result:
		result['move'] = 0
		if result.collider:
			if is_foe(result):
				new_result['flee'] = true
			if is_wall(result):
				new_result['wall'] = true
	return new_result

# throw out some rays so fish can tell what is around it.
# we populate the allowed directions
# flee is true if we should flee, otherwise flee is false
# flee should only be true for fish same size or bigger
# flee should not be true for walls
func check_environment()-> String:
	var rayLength = 50.0 * stats.fishSize
	var result
	var check_result
	
	result = shoot_physics_ray(Vector2.UP * rayLength)
	check_result = check_raycast_result(result,{})
	avoidUp = check_result['move'] * -1
	
	result = shoot_physics_ray(Vector2.DOWN * rayLength)
	check_result = check_raycast_result(result,check_result)
	avoidDown = check_result['move']
		
	result = shoot_physics_ray(Vector2.RIGHT * rayLength)
	check_result = check_raycast_result(result,check_result)
	avoidRight = check_result['move']
		
	result = shoot_physics_ray(Vector2.LEFT * rayLength)
	check_result = check_raycast_result(result,check_result)
	avoidLeft = check_result['move'] * -1
	
	if check_result.has('flee'):
		return 'flee'
	if check_result.has('wall'):
		return 'wall'
	
	return ''

func shoot_physics_ray(direction: Vector2) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + direction)
	query.exclude = [self]
	return space_state.intersect_ray(query)
	
func process_lung(delta: float) -> void:
	myLung._process(delta)

func process_food(delta: float) -> void:
	myStomach._process(delta)

func process_health(delta: float) -> void:
	# The fish will expend energy on fighting infection
	if stats.currentHealth < maxHealth:
		var energyRequired = delta * GameManager.infectionEnergy
		var energyReceived = myStomach.get_energy(energyRequired)
		var o2Used = myLung.requestO2(energyReceived)
		myStomach.receive_nh3(energyReceived / 4.0)
		if energyReceived == energyRequired and o2Used == energyReceived:
			stats.currentHealth += delta
	if stats.currentHealth > maxHealth:
		stats.currentHealth = maxHealth
	
	# poor water quality will assist the growing infection
	if GameManager.currentTankData.currentNH3 > GameManager.nh3HealthThreshold:
		stats.currentHealth -= delta / 2.0
	
	if stats.currentHealth == 0:
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
		
	# Fish cannot fly out of water
	if position.y <= 28:
		velocity.y += GameManager.GRAVITY * delta

	use_muscle_energy(delta)
	
	# collide with walls and eat food
	var collision = move_and_collide(velocity * delta)
	stats.globalPosition = global_position
	if collision:
		if collision.get_collider().has_method("eat"):
			eat_food(collision.get_collider())


func use_muscle_energy(delta: float) -> void:
	# energy is needed to accelerate
	var velocityDiff =  velocity.length_squared() - oldVelocity.length_squared()
	if velocityDiff > 0:
		var energyRequired = (velocityDiff / swimSpeed) * delta * stats.fishSize
		var energyReceived = myStomach.get_energy(energyRequired)
		var o2Used = myLung.requestO2(energyReceived)
		# stash waste in the stomach (well sorta kidneys bladder)
		myStomach.receive_nh3(energyReceived / 4.0)
		if energyReceived < energyRequired:
			if oldVelocity.length_squared() > 2:
				velocity = oldVelocity
		else:
			if o2Used < energyReceived:
				stats.currentHealth -= delta

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
	if(abs(velocity.x)) > swimSpeed / 10.0:
		GameManager.currentTankData.add_waste(myStomach.flush_waste(1.0 * delta))
		GameManager.currentTankData.add_nh3(myStomach.flush_nh3(1.0 * delta))

#Currently never called. just here for reference
func rotate_to_target(target, delta):
	direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func rotate_to_direction(newDirection: Vector2, delta: float) -> void:
	var angleTo = transform.x.angle_to(newDirection)
	var angleDelta = sign(angleTo) * min(delta * rotationSpeed, abs(angleTo))
	if velocity.x < 0:
		rotation_degrees -= angleDelta 
	else:
		rotation_degrees += angleDelta


func start_idle_timer(shorter: bool = true):
	if !idleTimerRunning:
		idleTimerRunning = true
		var maxWait = 6.0
		if shorter:
			maxWait = 6.0	
		idle_timer.start(randf_range(3.0,maxWait))


func find_food():
	if food_is_near():
		nearestFoodPosition = get_nearest_food().global_position
		if nearestFoodPosition != Vector2.ZERO:
			navagent.set_target_position(nearestFoodPosition)
	else:
		direction = Vector2.ZERO

func eat_food(foodObject: Node):
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

func _on_idle_timer_timeout():
	if fsm.currentState.has_method("on_idle_timer_timeout"):
		fsm.currentState.on_idle_timer_timeout()
	idleTimerRunning = false


# The mouse is hovering over us
func _on_mouse_entered():
	GameManager.set_fish(stats)
	

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
