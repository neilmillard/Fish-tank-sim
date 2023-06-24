extends State
class_name FishState

var fishBody: FishBody

func _ready() -> void:
	await owner.ready
	fishBody = owner as FishBody
	assert(fishBody != null)

func check_preditors(currentState: String):
	var detection = fishBody.check_environment()
	if detection == 'flee':
		emit_signal("Transitioned", currentState, "Fleeing", {"previousState" = currentState})
