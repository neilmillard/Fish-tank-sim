class_name UIMessage extends Control

@onready var label : Label = $Panel/Label
@onready var timer : Timer = $Timer

func set_message(message : String) -> void:
	if message.length() > 13:
		print("Message length 13 exceeding for: %s" % message)
	label.text = message
	timer.start(GameManager.MESSAGE_DISPLAY_TIME)

func remove() -> void:
	if is_inside_tree():
		get_parent().remove_child(self)


func _on_timer_timeout():
	remove()
