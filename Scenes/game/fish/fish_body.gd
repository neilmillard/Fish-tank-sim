extends CharacterBody2D
class_name FishBody

@export var stats: Fish
@export var myStomach: Stomach
@export var myLung: Lung
@export var myCharacter: FishCharacter

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var navagent: NavigationAgent2D = $NavigationAgent
@onready var fsm : StateMachine = $StateMachine
@onready var thought : Thought = $Thought
@onready var interactionArea : InteractionArea = $InteractionArea2D
@onready var idle_timer = $IdleTimer

var fishFaceRight: bool
var fishState: String = ""
var currentSwimspeed: float
var nearestFoodPosition: Vector2
var idleTimerRunning: bool = false
var direction: Vector2
var oldVelocity: Vector2
var swimTime: float
var idleTime: float
var avoidUp: int = -1
var avoidDown: int = -1
var avoidLeft: int = -1
var avoidRight: int = -1
var healthBar: ProgressBar
var healthBarStyleBox: StyleBox

var _timer = null
var debug := true
var debugLines = []

func _ready():
	$Sprite2D.texture = myCharacter.get_sprite()
	myStomach = stats.myStomach
	myStomach.capacity = stats.fishSize * GameManager.STOMACH_CAPACITY_BASE
	myLung = stats.myLung
	# set so we get collision events from mouse
	input_pickable = true
	currentSwimspeed = myCharacter.swimSpeed
	$CollisionShape2D.scale = Vector2(
				stats.fishSize * myCharacter.spriteScale, 
				stats.fishSize * myCharacter.spriteScale
			)
	fishFaceRight = true
	animationPlayer.play("SwimRight")
	start_idle_timer(true)
	add_debug_timer()
	add_health_bar()
	$StateMachine.parentNode = self
	if interactionArea:
		interactionArea.parentNode = self

func _process(delta):
	if fsm.currentState.name == "Dead":
		return
	process_lung(delta)
	process_food(delta)
	process_waste(delta)
	process_health(delta)
	process_growth(delta)
	scale_fish()

func _physics_process(delta):
	calculate_movement(delta)
	update_animation()

# Only run once per frame if queue_redraw() is called
func _draw():
	var col
	for line in debugLines:
		col = Color(255, 0, 0, 0.6) if line[2] else Color(0, 255, 0, 0.2)
		draw_line(line[0] - global_position, line[1] - global_position, col, 1)

func _on_debug_timeout():
	pass

func add_health_bar() -> void:
	healthBar = ProgressBar.new()
	healthBar.show_percentage = false
	healthBarStyleBox = StyleBoxFlat.new()
	healthBar.add_theme_stylebox_override("fill", healthBarStyleBox)
	healthBar.position = Vector2(-30.0, -80.0)
	healthBar.size = Vector2(60.0, 10.0)
	healthBar.max_value = myCharacter.maxHealth
	add_child(healthBar)
	

func set_health_bar() -> void:
	healthBar.value = stats.currentHealth
	if healthBar.value < myCharacter.maxHealth * 0.8:
		healthBar.show()
	if healthBar.value > myCharacter.maxHealth * 0.8:
		healthBar.hide()
	var bg_color = Color(0.2, 1.0, 0)
	if healthBar.value < myCharacter.maxHealth / 2:
		bg_color = Color(1.0, 0.0, 0)
	var sb = healthBar.get_theme_stylebox("fill")
	sb.bg_color = bg_color
	

func get_safe_direction():
	var myDirection = Vector2(
			randi_range(avoidLeft,avoidRight),
			randi_range(avoidUp,avoidDown)
			)
	if myDirection == Vector2.ZERO:
		myDirection = Vector2.UP
	return myDirection
	

func is_wall(collider) -> bool:
	if collider.collision_layer:
		if collider.collision_layer == GameManager.WALLS:
			return true
		if collider.collision_layer == GameManager.FLOOR:
			return true
	return false

func is_preditor(otherFish: FishBody) -> bool:
	if otherFish.fsm.currentState.name.to_lower() == "dead":
		return false
	if stats.fishSize < otherFish.stats.fishSize / 2.0:
		return true
	if stats.fishSize < otherFish.stats.fishSize && otherFish.myStomach.could_eat():
		return true
	return false

func is_mate(otherFish: FishBody) -> bool:
	if stats.isMale != otherFish.stats.isMale && stats.type == stats.type:
		# possible mate
		if otherFish.fsm.currentState.name == "Mating":
			return true
		else:
			return false
	else:
		return false

# throw out some rays so fish can tell what is around it.
# we populate the allowed directions used by 
# flee is true if we should flee, otherwise flee is false
# flee should only be true for fish same size or bigger
# flee should not be true for walls
# TODO: We will update this to check the interactions array instead
# on_area_entered will add an item to the array, which we can check
# for location and type.
func check_environment() -> String:
	if debug:
		debugLines = []
		
	avoidUp = -1
	avoidRight = 1
	avoidDown = 1
	avoidLeft = -1
	
	var bodies = interactionArea.bodies
	var locationDiff : Vector2
	if bodies.size() >= 1:
		for body in bodies:
			if(body.get_collision_layer_value(GameManager.WALLS)):
				locationDiff =  body.position - position
				if locationDiff.x < 0:
					avoidLeft = 0
				else:
					avoidRight = 0
			if(body.get_collision_layer_value(GameManager.FISH)):
				locationDiff =  body.position - position
				if is_preditor(body):
					if locationDiff.x < 0:
						avoidLeft = 0
					else:
						avoidRight = 0
					if locationDiff.y < 0:
						avoidUp = 0
					else:
						avoidDown = 0
					return 'flee'
				if is_mate(body):
					return 'mate'
			if(body.get_collision_layer_value(GameManager.FLOOR)):
				locationDiff =  body.position - position
				if locationDiff.y < 0:
					avoidUp = 0
				else:
					avoidDown = 0
	return ''


func shoot_physics_ray(p_direction: Vector2) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + p_direction)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if debug:
		queue_redraw()
		debugLines.append([global_position, global_position + p_direction, result != {}])
	return result
	
func process_lung(delta: float) -> void:
	myLung._process(delta)

func process_food(delta: float) -> void:
	myStomach._process(delta, myCharacter.preferredTemp, myCharacter.toleranceRange)

func process_health(delta: float) -> void:
	# The fish will expend energy on fighting infection
	var energyRequired
	stats.currentHealth -= delta
	if stats.currentHealth < myCharacter.maxHealth * 0.8:
		energyRequired = delta * GameManager.infectionEnergy * stats.fishSize
	else:
		energyRequired = delta * GameManager.infectionEnergy / 2.0
	var energyReceived = myStomach.get_energy(energyRequired)
	var o2Used = myLung.requestO2(energyReceived)
	myStomach.receive_nh3(energyReceived / 4.0)
	if energyReceived == energyRequired and o2Used == energyReceived:
		stats.currentHealth += delta * 1.1
	if stats.currentHealth > myCharacter.maxHealth:
		stats.currentHealth = myCharacter.maxHealth
	
	# poor water quality will assist the growing infection
	if GameManager.currentTankData.currentNH3 > GameManager.nh3HealthThreshold:
		stats.currentHealth -= delta / 2.0
	set_health_bar()

func process_growth(delta: float) -> void:
	# The fish will grow to maxSize provided it has enough energy
	if stats.fishSize >= myCharacter.maxSize:
		return
	if myStomach.storedEnergy < myCharacter.growthThreshold:
		return
	if stats.currentHealth < myCharacter.maxHealth * 0.80:
		return
	
	var energyRequired = delta * GameManager.growEnergy
	var energyReceived = myStomach.get_energy(energyRequired)
	var _o2Used = myLung.requestO2(energyReceived)
	myStomach.receive_nh3(energyReceived / 4.0)
	stats.fishSize += (energyReceived / GameManager.growRatio)

func scale_fish():
	var myScale = Vector2(
				stats.fishSize * myCharacter.spriteScale, 
				stats.fishSize * myCharacter.spriteScale
			)
	$Sprite2D.scale = myScale
	var collshape = $CollisionShape2D
	collshape.scale = Vector2(stats.fishSize, stats.fishSize)
	if interactionArea:
		interactionArea.set_size(stats.fishSize)
	

func kill_fish():
	GameManager.remove_fish_resource(stats)
	queue_free()

func calculate_movement(delta):
	if fsm.currentState.name == "Dead":
		move_and_collide(velocity * delta)
		return
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
		var energyRequired = (velocityDiff / myCharacter.swimSpeed) * delta * stats.fishSize
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
	if fsm.currentState.name == "Dead":
		if animationPlayer.is_playing():
			animationPlayer.stop()
		return
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
	if(abs(velocity.x)) > myCharacter.swimSpeed / 10.0:
		GameManager.currentTankData.add_waste(myStomach.flush_waste(1.0 * delta))
		var nh3Flushed = GameManager.currentTankData.add_nh3(myStomach.flush_nh3(1.0 * delta))
		myStomach.flush_nh3(nh3Flushed, true)
		
#Currently never called. just here for reference
func rotate_to_target(target, delta):
	direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(sign(angleTo) * min(delta * myCharacter.rotationSpeed, abs(angleTo)))

func rotate_to_direction(newDirection: Vector2, delta: float) -> void:
	var angleTo = transform.x.angle_to(newDirection)
	var angleDelta = sign(angleTo) * min(delta * myCharacter.rotationSpeed, abs(angleTo))
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
		nearestFoodPosition = get_nearest_food(position).global_position
		if nearestFoodPosition != Vector2.ZERO:
			navagent.set_target_position(nearestFoodPosition)
	else:
		direction = Vector2.ZERO

func could_eat() -> bool:
	return myStomach.could_eat()

func eat_food(foodObject: Node):
	if foodObject:
		# Dead fish cannot eat
		if fsm.currentState.name == "Dead":
			return
		if myStomach.has_space_to_eat(foodObject.nutritionValue.size):
			myStomach.receive_food(foodObject.eat())
		nearestFoodPosition = Vector2.ZERO

func get_current_swimSpeed():
	var modifier = GameManager.temperatureModifer(myCharacter.preferredTemp, 
												myCharacter.toleranceRange)
	var speed = (myCharacter.swimSpeed / 2.0 +
				myCharacter.swimSpeed * modifier / 2.0)
	return speed

func get_nearest_food(from: Vector2):
	var resources = get_tree().get_nodes_in_group("food")
	if resources.is_empty():
		# No food found
		return null
	var food = resources[0]
	for i in resources:
		if i.position.distance_to(from) < food.position.distance_to(from):
			food = i
	return food

func preditor_is_near():
	return false

func food_is_near():
	var food = get_nearest_food(position)
	if food:
		if food.position.distance_to(position) < myCharacter.idleFoodDistanceThreshold:
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

func _on_state_machine_state_changed():
	thought.start_thought(fsm.currentState.name)
	
