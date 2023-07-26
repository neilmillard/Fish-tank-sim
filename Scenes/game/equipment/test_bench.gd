extends Control

const AMM000 = Color8(235, 191, 26, 192)
const AMM025 = Color8(208, 197,12, 192)
const AMM050 = Color8(173, 184, 17, 192)
const AMM100 = Color8(121, 160, 25, 192)
const AMM200 = Color8(61, 133, 15, 192)
const AMM400 = Color8(11, 103, 26, 192)
const AMM800 = Color8(5, 64, 19, 192)

const RITE000 = Color8(146, 189,163, 192)
const RITE025 = Color8(147, 118, 162, 192)
const RITE050 = Color8(152, 90, 149, 192)
const RITE100 = Color8(134, 69, 111, 192)
const RITE200 = Color8(140, 53, 96, 192)
const RITE500 = Color8(135, 47, 93, 192)

const RATE000 = Color8(235, 215, 31, 192)
const RATE005 = Color8(229, 154, 29, 192)
const RATE010 = Color8(227, 111, 28, 192)
const RATE020 = Color8(214, 90, 30, 192)
const RATE040 = Color8(204, 41, 21, 192)
const RATE080 = Color8(205, 36, 31, 192)
const RATE160 = Color8(151, 32, 22, 192)

const PH60 = Color8(234, 200, 43, 192)
const PH64 = Color8(205, 188, 84, 192)
const PH66 = Color8(173, 181, 76, 192)
const PH68 = Color8(144, 171, 96, 192)
const PH70 = Color8(105, 163, 100, 192)
const PH72 = Color8(86, 156, 116, 192)
const PH76 = Color8(46, 138, 149, 192)

@onready var timer = $CooldownTimer

var cooldownExpired = true

func _init():
	GameManager.connect("run_test_button_pressed", run_test)
	hide()


func run_test():
	if is_visible_in_tree():
		hide()
		return
	
	if cooldownExpired:
		cooldownExpired = false
		timer.start(60)
		$Panel/TestBench/TestTubepH.set_color(PH70)
		var ammColor = get_nh3_color()
		$Panel/TestBench/TestTubeNH3.set_color(ammColor)
		
		var nitriteColor = get_no2_color()
		$Panel/TestBench/TestTubeNO2.set_color(nitriteColor)
		
		var nitrateColor = get_no3_color()
		$Panel/TestBench/TestTubeNO3.set_color(nitrateColor)

		show()
	else:
		var timeLeft = timer.time_left
		GameManager.display_warning_message("Test Unlock in %2.0fS" % timeLeft)

func get_nh3_color() -> Color:
	var ppm = GameManager.get_nh3_ppm()
	if ppm > 0.08: # 8%
		return AMM800
	if ppm > 0.04:
		return AMM400
	if ppm > 0.02:
		return AMM200
	if ppm > 0.01:
		return AMM100
	if ppm > 0.005:
		return AMM050
	if ppm > 0.0025:
		return AMM025
	return AMM000

func get_no2_color() -> Color:
	var ppm = GameManager.get_no2_ppm()
	if ppm > 0.05:
		return RITE500
	if ppm > 0.02:
		return RITE200
	if ppm > 0.01:
		return RITE100
	if ppm > 0.005:
		return RITE050
	if ppm > 0.0025:
		return RITE025
	return RITE000

func get_no3_color() -> Color:
	var ppm = GameManager.get_no3_ppm()
	
	if ppm > 0.16:
		return RATE160
	if ppm > 0.08:
		return RATE080
	if ppm > 0.04:
		return RATE040
	if ppm > 0.02:
		return RATE020
	if ppm > 0.01:
		return RATE010
	if ppm > 0.005:
		return RATE005
	return RATE000


func _on_close_button_button_down():
	hide()


func _on_cooldown_timer_timeout():
	cooldownExpired = true
