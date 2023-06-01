extends Control

const CAMERA_SPEED = 200
@onready var middleWater: MiddleWater = $"../../MiddleWater"
@onready var camera_focus = $"../../Camera_Focus"
@onready var camera = $"../../Camera_Focus/Camera2D"


var mousePosGlobal: Vector2
var cam_velocity: Vector2

func _ready():
	pass
	
func _process(delta):
	check_camera_moves(delta)
	update_inventory_display()
	update_fish_display()
	if Input.is_action_just_released("MouseLeft"):
		mousePosGlobal = get_global_mouse_position()
		if GameManager.currentFish:
			GameManager.currentCameraTarget = GameManager.currentFish
		else:
			GameManager.currentCameraTarget = null
		
func check_camera_moves(delta: float):
	if GameManager.currentCameraTarget:
		camera_focus.position = GameManager.currentCameraTarget.position
	else:
		var directionx = Input.get_axis("ui_left", "ui_right")
		if directionx:
			cam_velocity.x = directionx * CAMERA_SPEED * delta
		else:
			cam_velocity.x = 0.0
		var directiony = Input.get_axis("ui_up", "ui_down")
		if directiony:
			cam_velocity.y = directiony * CAMERA_SPEED * delta
		else:
			cam_velocity.y = 0.0
		camera_focus.position += cam_velocity
	
	camera_focus.position.x = clamp(
		camera_focus.position.x, 
		(1060 * camera.zoom.x) /2, 
		GameManager.currentLevelWidth - ((1060 * camera.zoom.x)/2)
		)
	camera_focus.position.y = clamp(
		camera_focus.position.y, 
		(604 * camera.zoom.y) /2, 
		GameManager.currentLevelHeight - ((604 * camera.zoom.y) /2)
		)

func update_inventory_display():
	$Control/ResourceContainer/FlakeFoodLabel/FlakeFoodValue.text = str(GameManager.flakeFood)
	$Control/ResourceContainer/LiveFoodLabel/LiveFoodValue.text = str(GameManager.liveFood)
	$Control/TankStatsContainer/TankO2Label/TankO2Value.text = str(floor(GameManager.currentTankData.get("availableO2")))
	$Control/TankStatsContainer/NH3Label/NH3Value.text = str(floor(GameManager.currentTankData.get("currentNH3")))
	$Control/TankStatsContainer/WasteLabel/WasteValue.text = str(floor(GameManager.currentTankData.get("currentWaste")))
	
func update_fish_display():
	if GameManager.currentFish != null:
		$Control/FishStateContainer/HungerLabel/HungerValue.text = str(floor(GameManager.currentFish.myStomach.get_amount_food_stored()))
		$Control/FishStateContainer/EnergyLabel/EnergyValue.text = str(floor(GameManager.currentFish.myStomach.get_stored_energy()))
		$Control/FishStateContainer/ActionLabel/ActionValue.text = GameManager.currentFish.fishState
	else:
		$Control/FishStateContainer/HungerLabel/HungerValue.text = ""
		$Control/FishStateContainer/EnergyLabel/EnergyValue.text = ""
		$Control/FishStateContainer/ActionLabel/ActionValue.text = ""

func _on_flake_food_button_button_down():
	if GameManager.flakeFood > 0:
		GameManager.flakeFood -= 1
		middleWater.spawn_flakefood()
		


func _on_spawn_fish_button_button_up():
	middleWater.spawn_fish()
	
