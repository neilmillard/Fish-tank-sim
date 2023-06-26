extends State
class_name FishState

var fishBody: FishBody

func _ready() -> void:
	await owner.ready
	fishBody = owner as FishBody
	assert(fishBody != null)

func check_preditors():
	var detection = fishBody.check_environment()
	return detection
