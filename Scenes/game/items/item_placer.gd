class_name ItemPlacer extends Node2D

var item_to_place: PlaceableItem:
	get:
		return item_to_place
	set(new_value):
		_clear_preview()
		item_to_place = new_value
		if new_value is PlaceableItem:
			_create_placement_preview()

var preview_instance: Placeable


func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if preview_instance != null:
		var mouse_position = get_global_mouse_position()
		var rounded_position = Vector2(int(round(mouse_position.x)), int(round(mouse_position.y)))
		preview_instance.global_position = rounded_position

func _unhandled_input(_event) -> void:
	if preview_instance == null:
		return
	
	if Input.is_action_just_pressed("MouseLeft"):
		_place_item()

func _create_placement_preview() -> void:
	if item_to_place == null:
		return
	
	# create preview
	if (item_to_place.placeable_scene_path 
		!= "res://Scenes/game/equipment/CanisterFilter.tscn"):
		print("Item scene path %s" % item_to_place.placeable_scene_path)
	var preview_scene = ResourceLoader.load(item_to_place.placeable_scene_path)
	preview_instance = preview_scene.instantiate() as Placeable
	preview_instance.init(item_to_place)
	# preview_instance.set_collision_enabled(false)
	
	#spawn into world
	GameManager.spawn_placeable_object(preview_instance)
	preview_instance.previewing = true

func _clear_preview() -> void:
	if preview_instance == null:
		return
	
	preview_instance.queue_free()

func _place_item() -> void:
	if preview_instance == null:
		return
	
	if !preview_instance.can_place:
		#TODO
		return
	
	# Remove item from stock
	print("Remove ITEM from inventory, that we placed")
	# preview_instance.set_collision_enabled(true)
	preview_instance.previewing = false
	# Save item properties so we can save/load
	preview_instance.set_stats()
	preview_instance = null
	item_to_place = null
