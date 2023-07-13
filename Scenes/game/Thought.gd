extends Node2D
class_name Thought

enum ThoughtStates {
	Closed,
	Opening,
	Closing, 
	Open
}

var bubbleShowTime :float = 4.0
var thoughts := {
	'Mating': ResourceLoader.load("res://art/heart_icon.png"),
	'Hunting': ResourceLoader.load("res://art/food_icon.png")
}

var state :ThoughtStates
var sprite: CompressedTexture2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var icon: Sprite2D = $Icon
@onready var _timer: Timer = $Timer

func _init():
	hide()
	state = ThoughtStates.Closed

func start_thought(thought: String) -> void:
	if state == ThoughtStates.Closed and thought in thoughts:
		sprite = thoughts[thought]
		state = ThoughtStates.Opening
		open()

func hide_thought() -> void:
	icon.texture = null
	state = ThoughtStates.Closing
	close()

func open() -> void:
	show()
	animationPlayer.play("open")

func close() -> void:
	animationPlayer.play("close")

func _on_animation_player_animation_finished(_anim_name):
	if state == ThoughtStates.Opening:
		icon.texture = sprite
		state = ThoughtStates.Open
		_timer.start(bubbleShowTime)
		return
	if state == ThoughtStates.Closing:
		hide()
		state = ThoughtStates.Closed
	
func _on_timer_timeout():
	hide_thought()
