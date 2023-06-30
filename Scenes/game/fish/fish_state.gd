extends State
class_name FishState

var myBody: FishBody

func _ready() -> void:
	# wait for stateMachine
	await owner.ready


func check_preditors():
	var detection = myBody.check_environment()
	return detection
