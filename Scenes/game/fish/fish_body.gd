class_name FishBody extends CharacterBody2D

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
@onready var message_timer: Timer

var can_print_message: bool = true
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
var potentialMate: FishBody
var mated := {}

var _timer = null
var _growBabyTimer = null
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
		show_fish_dying_message()
	var sb = healthBar.get_theme_stylebox("fill")
	sb.bg_color = bg_color
	
func show_fish_dying_message() -> void:
	if not message_timer:
		message_timer = Timer.new()
		add_child(message_timer)
		message_timer.connect("timeout", Callable(self, "_on_message_timeout"))
		message_timer.set_wait_time(15.0)
		message_timer.set_one_shot(true) # so it no loop
		
	if message_timer and can_print_message:
		can_print_message = false
		GameManager.display_warning_message("Fish Dying")
		message_timer.start()

func _on_message_timeout() -> void:
	can_print_message = true


func get_safe_direction():
	var myDirection = Vector2(
			randi_range(avoidLeft,avoidRight),
			randi_range(avoidUp,avoidDown)
			)
	if direction.x > avoidLeft and direction.x < avoidRight:
		myDirection.x = direction.x
	if direction.y > avoidUp and direction.y < avoidUp:
		myDirection.y = direction.y
	
	if myDirection == Vector2.ZERO:
		if position.y > GameManager.currentLevelHeight:
			myDirection = Vector2.UP
		else:
			myDirection = Vector2.DOWN
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
	if (stats.fishSize < otherFish.stats.fishSize 
		and otherFish.myStomach.could_eat()
		):
		return true
	return false

func is_mate_ready(otherFish: FishBody) -> bool:
	if is_mate(otherFish.stats):
		# possible mate
		if otherFish.fsm.currentState.name == "Mating":
			potentialMate = otherFish
			return true
	potentialMate = null
	return false

func is_mate(otherFish: Fish) -> bool:
	if (stats.isMale != otherFish.isMale 
		and stats.type == otherFish.type ):
			if otherFish.fishSize >= myCharacter.mateSize:
				return true
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
				if is_mate_ready(body):
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
	var query = PhysicsRayQueryParameters2D.create(
		global_position, 
		global_position + p_direction
		)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if debug:
		queue_redraw()
		debugLines.append(
			[global_position, global_position + p_direction, result != {}]
			)
	return result
	
func process_lung(delta: float) -> void:
	myLung._process(delta)

func process_food(delta: float) -> void:
	myStomach._process(
		delta, 
		myCharacter.preferredTemp, 
		myCharacter.toleranceRange
		)

func process_health(delta: float) -> void:
	# The fish will expend energy on fighting infection
	stats.currentHealth -= delta
	var healthRatio = 1 - (stats.currentHealth / myCharacter.maxHealth)
	var energyRequired = (
		delta * GameManager.infectionEnergy * stats.fishSize * healthRatio
		)
	var energyReceived = myStomach.get_energy(energyRequired)
	var o2Used = myLung.requestO2(energyReceived)
	myStomach.receive_nh3(energyReceived / 4.0)
	if energyReceived == energyRequired and o2Used == energyReceived:
		stats.currentHealth += delta * 1.1
	if stats.currentHealth > myCharacter.maxHealth:
		stats.currentHealth = myCharacter.maxHealth
	
	# poor water quality will assist the growing infection
	if GameManager.get_nh3_ppm() > GameManager.nh3PpmHealthThreshold:
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
		var energyRequired = (
			(velocityDiff / myCharacter.swimSpeed) * delta * stats.fishSize
		)
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
		var nh3Flushed = GameManager.currentTankData.add_nh3(
			myStomach.flush_nh3(1.0 * delta)
		)
		myStomach.flush_nh3(nh3Flushed, true)
		
#Currently never called. just here for reference
func rotate_to_target(target, delta):
	direction = target.global_position - global_position
	var angleTo = transform.x.angle_to(direction)
	transform.rotated(
		sign(angleTo) * min(delta * myCharacter.rotationSpeed, 
		abs(angleTo))
		)

func rotate_to_direction(newDirection: Vector2, delta: float) -> void:
	if newDirection.x == 0:
		newDirection.x = 1
	var angleTo = transform.x.angle_to(newDirection)
	var angleDelta = sign(angleTo) * min(
			delta * myCharacter.rotationSpeed, abs(angleTo)
		)
	if velocity.x < 0:
		rotation_degrees -= angleDelta 
	else:
		rotation_degrees += angleDelta
	
func start_idle_timer(shorter: bool = true):
	if not idleTimerRunning:
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
		if myStomach.has_space_to_eat(
				foodObject.myCharacter.nutritionValue.size
			):
			myStomach.receive_food(foodObject.eat())
		nearestFoodPosition = Vector2.ZERO

func get_stored_energy() -> float:
	return myStomach.storedEnergy

## returns storedEnergy threshold required to enter mating
func over_mating_threshold() -> float:
	var enoughEnergy = get_stored_energy() > myCharacter.matingEnergyThreshold
	var oldEnough = stats.fishSize > myCharacter.mateSize
	var healthy = stats.currentHealth > 0.8 * myCharacter.maxHealth
	return enoughEnergy and oldEnough and healthy and not stats.isExpecting

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
		if (food.position.distance_to(position) 
		< 
		myCharacter.idleFoodDistanceThreshold):
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
	var myThought = fsm.currentState.name
	if randi_range(0,10) > 5:
		var modifier = GameManager.temperatureModifer(myCharacter.preferredTemp, 
												myCharacter.toleranceRange)
		if modifier < 0.25:
			if myCharacter.preferredTemp > GameManager.get_tank_temp():
				myThought = "Cold"
			else:
				myThought = "Hot"
				
	thought.start_thought(myThought)

func expire_mated():
	var timeLimit = myCharacter.growBabyTime * 1000  # Time limit milliseconds
	var currentTime = Time.get_ticks_msec()
	var itemsToRemove = []
	
	for key in mated:
		var item = mated[key]
		var timestamp = item
		var timeDifference = currentTime - timestamp

		if timeDifference > timeLimit:
			itemsToRemove.append(key)

	for item_key in itemsToRemove:
		mated.erase(item_key)

func mate(otherFish: FishBody = null):
	if potentialMate:
		if stats.isMale:
			var _matingEnergy = myStomach.get_energy(20.0)
			mated[potentialMate.stats.id] = Time.get_ticks_msec()
			potentialMate.mate(self)
			return
	if otherFish and not stats.isMale:
		if not _growBabyTimer:
			grow_baby()

func grow_baby():
	stats.isExpecting = true
	_growBabyTimer = Timer.new()
	add_child(_growBabyTimer)
	_growBabyTimer.connect("timeout", Callable(self, "_on_grow_baby_timeout"))
	_growBabyTimer.set_wait_time(myCharacter.growBabyTime)
	_growBabyTimer.set_one_shot(true)
	_growBabyTimer.start()
	print("%s Growing a baby" % name)

func _on_grow_baby_timeout():
	stats.isExpecting = false
	_growBabyTimer.queue_free()
	var _babyEnergy = myStomach.get_energy(40.0)
	# TODO: maybe more that one, smaller and less energy on spawn
	var childrenDropped = randi_range(
			myCharacter.minChildren, 
			myCharacter.maxChildren
		)
	print("%s Baby spawn %s" % [name, childrenDropped])
	for i in range(childrenDropped):
		GameManager.spawn_new_object(
			stats.type, 
			Vector2(position.x, position.y + 10*i)
		)

func get_nearest_mates(detectionDistance: float) -> Array[Fish]:
	var fishes = GameManager.get_fish_mates(stats.type, not stats.isMale)
	var mates : Array[Fish] = []
	for fish in fishes:
		if fish.globalPosition.distance_to(position) < detectionDistance:
			mates.append(fish)
	return mates

func has_mated(fish: Fish) -> bool:
	if fish.id in mated:
		return true
	return false
