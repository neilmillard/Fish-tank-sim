extends Sprite2D

var resultColor : Color

const AMM000 = Color8(235, 191, 26, 128)
const AMM025 = Color8(208, 197,12, 128)
const AMM050 = Color8(173, 184, 17, 128)
const AMM100 = Color8(121, 160, 25, 128)
const AMM200 = Color8(61, 133, 15, 128)
const AMM400 = Color8(11, 103, 26, 128)
const AMM800 = Color8(5, 64, 19, 128)

const RITE000 = Color8(146, 189,163, 128)
const RITE025 = Color8(147, 118, 162, 128)
const RITE050 = Color8(152, 90, 149, 128)
const RITE100 = Color8(134, 69, 111, 128)
const RITE200 = Color8(140, 53, 96, 128)
const RITE500 = Color8(135, 47, 93, 128)

const RATE000 = Color8(235, 215, 31, 128)
const RATE050 = Color8(229, 154, 29, 128)
const RATE010 = Color8(227, 111, 28, 128)
const RATE020 = Color8(214, 90, 30, 128)
const RATE040 = Color8(204, 41, 21, 128)
const RATE080 = Color8(205, 36, 31, 128)
const RATE160 = Color8(151, 32, 22, 128)

const PH60 = Color8(234, 200, 43, 128)
const PH64 = Color8(205, 188, 84, 128)
const PH66 = Color8(173, 181, 76, 128)
const PH68 = Color8(144, 171, 96, 128)
const PH70 = Color8(105, 163, 100, 128)
const PH72 = Color8(86, 156, 116, 128)
const PH76 = Color8(46, 138, 149, 128)

func _init():
	resultColor = Color(0.5, 0.0, 0.0, 0.5)
	queue_redraw()

func set_color(col: Color):
	resultColor = col
	queue_redraw()
	
func _draw():
	var myPos = Vector2(1,10)
	draw_rect(Rect2(myPos, Vector2(12, 55)), resultColor, true)
	

