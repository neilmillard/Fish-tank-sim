extends MarginContainer

@onready var warning_messages_container = $MessagesContainer
@onready var message_scene = preload("res://Scenes/menu/ui_message.tscn")

var message_container_pool:Array[UIMessage] = []

func _ready() -> void:
	GameManager.connect("show_warning_message", spawn_message)

func spawn_message(message:String) -> void:
	var message_container = get_message_container()
	message_container.set_message(message)
	add_child(message_container)

func get_message_container() -> UIMessage:
	if message_container_pool.size() > 0:
		return message_container_pool.pop_back()
	else:
		var new_message_scene = message_scene.instantiate()
		new_message_scene.tree_exiting.connect(
			func():message_container_pool.append(new_message_scene)
		)
		return new_message_scene
