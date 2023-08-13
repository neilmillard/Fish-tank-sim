extends Control

const CAMERA_SPEED = 200
const COLOR_CRITICAL = Color(0.95, 0.25, 0.25)
const COLOR_WARNING = Color(0.7, 0.7, 0.1)

@onready var camera_focus = $"../../Camera_Focus"
@onready var camera = $"../../Camera_Focus/Camera2D"


var mousePosGlobal: Vector2
var cam_velocity: Vector2

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_pause"):
		GameManager.trigger_game_paused()

func _process(delta):
	check_camera_moves(delta)
	update_inventory_display()
	if Input.is_action_just_released("MouseLeft"):
		mousePosGlobal = get_global_mouse_position()
		if GameManager.currentFish:
			GameManager.currentCameraTarget = GameManager.currentFish
		else:
			GameManager.currentCameraTarget = null

func _unhandled_input(event) -> void:
#	if event is InputEventMouseButton:
#		if event.get_button_index() == MOUSE_BUTTON_RIGHT:
#			GameManager.display_warning_message("Right Mouse Pressed")
	pass

func check_camera_moves(delta: float):
	if GameManager.currentCameraTarget:
		camera_focus.position = GameManager.currentCameraTarget.globalPosition
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
		GameManager.currentLevelHeight + 80 - ((604 * camera.zoom.y) /2)
		)

func update_inventory_display():
	$Panel/HCont/ResourceContainer/MarginContainer/FlakeFoodLabel/FlakeFoodValue.text = str(GameManager.flakeFood)
	$Panel/HCont/ResourceContainer/MarginContainer2/LiveFoodLabel/LiveFoodValue.text = str(GameManager.liveFood)
	$Panel/HCont/MarginContainer/TankTemp/HBoxContainer/TargetTemp.text = "%2.0f" % GameManager.currentTankData.get("targetTemp")
	if GameManager.has_heater():
		$Panel/HCont/MarginContainer/TankTemp/HBoxCont/TankTempValue.text = "%4.2f" % GameManager.currentTankData.get("currentTemp")
	else:
		$Panel/HCont/MarginContainer/TankTemp/HBoxCont/TankTempValue.text = "NA"

	# Tank Chemistry
	$Panel/HCont/TankStatsContainer/FishCountLabel/FishCountValue.text = "%4.0f" % GameManager.currentFishInTank()
	$Panel/HCont/TankStatsContainer/WasteLabel/WasteValue.text = "%4.2f" % GameManager.currentTankData.get("currentWaste")
	$Panel/HCont/TankStatsContainer/FoodQuantLabel/FoodQuantValue.text = "%4.0f" % GameManager.currentFoodInTank()
	$Panel/HCont/TankStatsContainer2/TankO2Label/TankO2Value.text = str(floor(GameManager.currentTankData.get("availableO2")))
	$Panel/HCont/TankStatsContainer2/NH3Label/NH3Value.text = "%4.2f" % GameManager.currentTankData.get("currentNH3")
	$Panel/HCont/TankStatsContainer2/NO3Label/NO3Value.text = "%4.2f" % GameManager.currentTankData.get("currentNO3")
	
	# Warnings
	if GameManager.get_nh3_ppm() > GameManager.nh3PpmHealthThreshold:
		$Panel/HCont/TankStatsContainer2/NH3Label/NH3Value.add_theme_color_override("font_color", COLOR_CRITICAL)
		GameManager.display_warning_message("Check Water")
	else:
		$Panel/HCont/TankStatsContainer2/NH3Label/NH3Value.remove_theme_color_override("font_color")
	
	if GameManager.currentFishInTank() > GameManager.currentFoodInTank():
		$Panel/HCont/TankStatsContainer/FoodQuantLabel/FoodQuantValue.add_theme_color_override("font_color", COLOR_WARNING)
		GameManager.display_warning_message("Check Food")
	else:
		$Panel/HCont/TankStatsContainer/FoodQuantLabel/FoodQuantValue.remove_theme_color_override("font_color")

func _on_flake_food_button_button_down():
	if GameManager.flakeFood > 0:
		GameManager.flakeFood -= 1
		GameManager.spawn_new_object("FlakeFood")
		

func _on_brine_shrimp_food_button_button_down():
	if GameManager.liveFood > 0:
		GameManager.liveFood -= 1
		GameManager.spawn_new_object("BrineShrimpFood")
	
func _on_spawn_fish_button_button_up():
	GameManager.spawn_new_object("OrangeFish")
	


func _on_spawn_green_fish_button_button_up():
	GameManager.spawn_new_object("GreenFish")


func _on_spawn_green_plant_button_button_up():
	GameManager.spawn_new_object("GreenPlant")


func _on_tank_temp_up_button_up():
	GameManager.set_tank_target_temp(1.0)


func _on_tank_temp_down_button_up():
	GameManager.set_tank_target_temp(-1.0)


func _on_water_test_button_button_down():
	GameManager.run_water_test()


func _on_water_change_button_button_down():
	GameManager.water_change()


func _on_place_canister_filter_button_button_up():
	GameManager.place_placeable_item('CanisterFilter')
