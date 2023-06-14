extends Node2D
class_name UnderwaterPrecedural


@export var flakeFood: Food


@onready var chunk_layers = get_children()

@export var tank_data : TankData

func _ready():
	tank_data = load("res://Resources/default_tank.tres")
	build(tank_data)
	
	
func build(tank: TankData) -> void:
	GameManager.set_current_level(tank)
	tank_data = tank
	
	for layer in chunk_layers:
		if layer.has_method("build"):
			layer.build(tank_data)
		else:
			print("layer " + str(layer.get_path()) + " has no build method")


func _on_save_tank_button_pressed():
	print("Save Tank")
	save_data()
	pass # Replace with function body.


func _on_load_tank_button_pressed():
	print("Load Tank")
	load_data()
	pass # Replace with function body.

static func save_exists() -> bool:
	return ResourceLoader.exists(GameManager.get_save_path())

func save_data() -> void:
	ResourceSaver.save(tank_data, GameManager.get_save_path())
#	var file = FileAccess.open(GameManager.SAVE_FILE, FileAccess.WRITE)
	
		# JSON provides a static method to serialized JSON string.
		# var json_string = JSON.stringify(node_data)
		# file.store_line(json_string)
#	file.store_var(tank_data, true)
#	file.close()

func load_data():
	if not FileAccess.file_exists(GameManager.SAVE_FILE):
		return # Error! We don't have a save to load.
	
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open(GameManager.SAVE_FILE, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var new_object = save_game.get_var(true)
		
		# new_object.instantiate()
		#var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		#var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		#var parse_result = json.parse(json_string)
		#if not parse_result == OK:
		#	print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		#	continue

		# Get the data from the JSON object
		#var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		# var new_object = load(node_data["filename"]).instantiate()
		#get_node(node_data["parent"]).add_child(new_object)
		#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		#for i in node_data.keys():
		#	if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
		#		continue
		#	new_object.set(i, node_data[i])

