extends CharacterBody2D

# Fish management
@export var swimSpeed: int = 60
@export var fleeSpeed: int = 100
@export var isMale: bool = true
@export var feedLevel: FeedLevel = FeedLevel.Middle

@onready var navagent : NavigationAgent2D = $NavigationAgent
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
var nearestFood
var idleFoodDistanceThreshold: float = 400

var fishDebugState: String = ""
var fishFoodStatus: String = ""
var _timer = null


func initFish(tank: TankData):
	myTank = tank

func _ready():
	animationPlayer = $AnimationPlayer
	change_state_to_idle()
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
	print(fishDebugState)
	if fishFoodStatus != "":
		print(fishFoodStatus)
		fishFoodStatus = ""
	print("hunger=%f" %[hunger])

func calculate_movement(delta):
	if currentState == FishStates.Feeding:
		nav_to_food()
	if currentState == FishStates.Idle:
		if velocity.length() > 0:
			velocity = velocity - velocity * (0.5 * delta)
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().has_method("eat"):
			eat_food(collision.get_collider())

func update_animation():
	if velocity.x < 0:
		animationPlayer.play("SwimLeft")
	else:
		animationPlayer.play("SwimRight")

func decide_next_action():
	match currentState:
		FishStates.Idle:
			fishDebugState = "Fish is Idle"
			# fish will only change from idle, if food, mate or preditor present
			if preditor_is_near():
				currentState = FishStates.Fleeing
			if hunger > 70:
				currentState = FishStates.Feeding
			if food_is_near() && hunger > 40:
				currentState = FishStates.Feeding
				
		FishStates.Feeding:
			fishDebugState = "Fish is Feeding"
			if nearestFood == null:
				find_food()
			if nearestFood == null:
				change_state_to_idle()

		FishStates.Fleeing:
			fishDebugState = "Fish is Fleeing"
			pass

		FishStates.Mating:
			fishDebugState = "Fish is Mating"
			pass
	return

func change_state_to_idle():
	currentState = FishStates.Idle
	idle_timer.start(randi_range(2,6))

func nav_to_food():
	if nearestFood:
		fishFoodStatus = "navigating to food"
		if navagent.is_navigation_finished():
			eat_food(null)
			return
		else:
			if nearestFood.sinking:
				navagent.set_target_position(nearestFood.global_position)
			var targetpos = navagent.get_next_path_position()
			if (targetpos == null):
				print("Cannot get to food")
				nearestFood = null
				return
			var direction = global_position.direction_to(targetpos)
			if direction != Vector2.ZERO:
				velocity = direction * swimSpeed

func find_food():
	fishFoodStatus = "finding nearest food"
	nearestFood = get_nearest_food()
	if nearestFood:
		navagent.set_target_position(nearestFood.global_position)
	return

func eat_food(foodObject):
	if foodObject:
		if hunger > foodObject.nutritionValue:
			hunger = hunger - foodObject.eat()
			fishFoodStatus = "ate food"
	nearestFood = null
	change_state_to_idle()


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
		# print("food is %f away" % food.position.distance_to(position))
		if food.position.distance_to(position) < idleFoodDistanceThreshold:
			return true
	return false

func pick_random_direction():
	var direction = Vector2(randi_range(-1,1),randi_range(-1,1))
	velocity = direction.normalized() * (swimSpeed / 2)

func _on_idle_timer_timeout():
	if currentState == FishStates.Idle:
		pick_random_direction()
		change_state_to_idle()
