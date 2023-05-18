extends Control

const CAMERA_SPEED = 200
@onready var middleWater = $"../MiddleWater"
var camera: Camera2D

var mousePosGlobal: Vector2
var cam_velocity: Vector2

func _ready():
	camera = get_viewport().get_camera_2d()
	camera.transform.origin = Vector2(camera.get_viewport().get_window().size.x / 2,
		camera.get_viewport().get_window().size.y / 2)
	#camera.limit_top = 0
	#camera.limit_left = 0
	#camera.limit_right = GameManager.CHUNK_WIDTH
	#camera.limit_bottom = GameManager.CHUNK_HEIGHT
	
func _process(delta):
	check_camera_moves(delta)
	update_inventory_display()
	update_fish_display()
	if Input.is_action_just_released("MouseLeft"):
		mousePosGlobal = get_global_mouse_position()
		
func check_camera_moves(delta: float):
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
	camera.transform.origin += cam_velocity

func update_inventory_display():
	$Control/VBoxContainer2/FlakeFoodLabel/FlakeFoodValue.text = str(GameManager.flakeFood)
	$Control/VBoxContainer2/LiveFoodLabel/LiveFoodValue.text = str(GameManager.liveFood)


func update_fish_display():
	if GameManager.currentFish != null:
		$Control/VBoxContainer/HungerLabel/HungerValue.text = str(floor(GameManager.currentFish.hunger))
		$Control/VBoxContainer/ActionLabel/ActionValue.text = GameManager.currentFish.fishState
	else:
		$Control/VBoxContainer/HungerLabel/HungerValue.text = ""
		$Control/VBoxContainer/ActionLabel/ActionValue.text = ""

func _on_flake_food_button_button_down():
	if GameManager.flakeFood > 0:
		GameManager.flakeFood -= 1
		middleWater.spawn_flakefood()
		
