extends Node2D
class_name UnderwaterPrecedural

# We always keep a reference to the SaveGame resource here to prevent it from 
# unloading.
var _save: SaveGame
var middleWater: MiddleWater

@onready var itemPlacer: ItemPlacer = $ItemPlacer
@onready var chunk_layers = get_children()

func _ready():
	_create_or_load_save()
	# Then we trigger the .build() functions
	build(_save.tankData)
	GameManager.connect("save_button_pressed", _on_save_tank_button_pressed)
	GameManager.connect("set_placeable_item", _on_set_placeable_item)
	
func build(tank: TankData) -> void:
	GameManager.set_current_level(tank)
	
	for layer in chunk_layers:
		if layer.has_method("build"):
			layer.build(tank)
		else:
			print("layer " + str(layer.get_path()) + " has no build method")
		
		# Find the middle layer, for spawning fish and food buttons
		if layer.has_method("spawn_obj"):
			middleWater = layer


func _on_save_tank_button_pressed():
	_save.tankData = GameManager.currentTankData
	_save.write_savegame()


func _create_or_load_save() -> void:
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame()
	else:
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
	
	
func _on_set_placeable_item(item: PlaceableItem) -> void:
	itemPlacer.item_to_place = item
