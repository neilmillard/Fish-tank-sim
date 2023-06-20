extends Node
class_name StateMachine

@export var initialState: State

var currentState: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_child_transition)
	
	if initialState:
		# wait for the readys to be complete
		await owner.ready
		initialState.enter()
		currentState = initialState
	
func _process(delta):
	if currentState:
		currentState.update(delta)

func _physics_process(delta):
	if currentState:
		currentState.physics_update(delta)

func _on_child_transition(state, newStateName, data={}):
	# ignore transitions not From our currentState
	if state != currentState.name:
		print("Child Transitioned from illegal state "+state+"->"+newStateName)
		print("Current State=" + currentState.name + "!=" + state)
		return
	
	var newState: State = states.get(newStateName.to_lower())
	if !newState:
		return
	
	if currentState:
		currentState.exit()
	
	newState.enter(data)
	
	currentState = newState