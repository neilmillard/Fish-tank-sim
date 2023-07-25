class_name UIMessage extends Control

@onready var label : Label = $Panel/Label
@onready var timer : Timer = $Timer

var currentMessage: String = ""

func set_message(message : String) -> void:
	await ready
	if message.length() > 19:
		print("Message length 19 exceeding for: %s" % message)
	label.text = message
	currentMessage = message
	timer.start(GameManager.MESSAGE_DISPLAY_TIME)

func remove() -> void:
	if is_inside_tree():
		get_parent().remove_child(self)

func _on_timer_timeout():
	remove()
