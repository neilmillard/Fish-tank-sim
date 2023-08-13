extends MarginContainer

@onready var warning_messages_container = $MessagesContainer
@onready var message_scene = preload("res://Scenes/menu/ui_message.tscn")

var message_container_pool:Array[UIMessage] = []
var live_messages:Array[String] = []

func _ready() -> void:
	GameManager.connect("show_warning_message", spawn_message)

func spawn_message(message:String) -> void:
	if message in live_messages:
		return
	var message_container = get_message_container()
	message_container.set_message(message)
	live_messages.append(message)
	warning_messages_container.add_child(message_container)
	if warning_messages_container.get_child_count() > 4:
		print("Warning More than 4 messages")

func remove_message(old_message_scene:UIMessage) -> void:
	message_container_pool.append(old_message_scene)
	live_messages.erase(old_message_scene.currentMessage)

func get_message_container() -> UIMessage:
	var new_message_scene
	if message_container_pool.size() > 0:
		new_message_scene = message_container_pool.pop_back()
	else:
		new_message_scene = message_scene.instantiate()
		new_message_scene.tree_exiting.connect(
			func():remove_message(new_message_scene)
		)
	new_message_scene.currentMessage = "BLANK"
	return new_message_scene
