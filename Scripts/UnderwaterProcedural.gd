extends Node2D
class_name UnderwaterPrecedural


@export var flakeFood: Food
# We always keep a reference to the SaveGame resource here to prevent it from unloading.
var _save: SaveGame

@onready var chunk_layers = get_children()

func _ready():
	_create_or_load_save()
	# Then we trigger the .build() functions
	build(_save.tankData)
	
	
func build(tank: TankData) -> void:
	GameManager.set_current_level(tank)
	
	for layer in chunk_layers:
		if layer.has_method("build"):
			layer.build(tank)
		else:
			print("layer " + str(layer.get_path()) + " has no build method")


func _on_save_tank_button_pressed():
	print("Save Tank")
	_save.tankData = GameManager.currentTankData
	_save.write_savegame()


func _on_load_tank_button_pressed():
	print("Load Tank")
	_create_or_load_save()

func _create_or_load_save() -> void:
	if SaveGame.save_exists():
		print("loading savegame")
		_save = SaveGame.load_savegame()
	else:
		print("creating savegame")
		_save = SaveGame.new()
		var tank_data = GameManager.currentTankData
		if !tank_data:
			tank_data = load("res://Resources/default_tank.tres").duplicate(true)
		_save.tankData = tank_data
		
		_save.write_savegame()

	if !_save:
		print("error loading")
	# After creating or loading a save resource, we need to dispatch its data
	# to the various nodes that need it.
	GameManager.currentTankData = _save.tankData
	
