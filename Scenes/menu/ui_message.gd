class_name UIMessage extends Control

@onready var timer : Timer = $Timer

var label : Label
var currentMessage: String = ""

func _ready():
	pass

func set_message(message : String) -> void:
	if not label:
		label = $Panel/Label
	if message.length() > 19:
		print("Message length 19 exceeding for: %s" % message)
	label.text = message
	currentMessage = message
	await ready
	timer.start(GameManager.MESSAGE_DISPLAY_TIME)

func remove() -> void:
	if is_inside_tree():
		get_parent().remove_child(self)

func _on_timer_timeout():
	remove()
