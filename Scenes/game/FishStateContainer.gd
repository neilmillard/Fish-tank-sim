extends VBoxContainer

func _physics_process(_delta):
	update_fish_display()
	
func update_fish_display():
	if GameManager.currentFish != null:
		$HungerLabel/HungerValue.text = "%4.2f" % GameManager.currentFish.myStomach.get_amount_food_stored()
		$EnergyLabel/EnergyValue.text = "%4.2f" % GameManager.currentFish.myStomach.get_stored_energy()
		$SizeLabel/SizeValue.text = "%4.2f" % GameManager.currentFish.fishSize
		$HealthLabel/HealthValue.text = "%4.2f" % GameManager.currentFish.currentHealth
		$SexLabel/SexValue.text = "%s" % GameManager.currentFish.isMale
	else:
		$HungerLabel/HungerValue.text = ""
		$EnergyLabel/EnergyValue.text = ""
		$SizeLabel/SizeValue.text = ""
		$HealthLabel/HealthValue.text = ""
		$SexLabel/SexValue.text = ""
