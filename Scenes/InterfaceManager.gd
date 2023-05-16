extends Control

@onready var middleWater = $"../MiddleWater"
var mousePosGlobal: Vector2

func _process(delta):
	update_inventory_display()
	update_fish_display()
	if Input.is_action_just_released("MouseLeft"):
		mousePosGlobal = get_global_mouse_position()
		
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
		
