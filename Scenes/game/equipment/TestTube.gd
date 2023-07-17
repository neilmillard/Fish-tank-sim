extends Sprite2D

var resultColor : Color

func _init():
	resultColor = Color(0.5, 0.0, 0.0, 0.5)
	queue_redraw()

func set_color(col: Color):
	resultColor = col
	queue_redraw()
	
func _draw():
	var myPos = Vector2(1,10)
	draw_rect(Rect2(myPos, Vector2(12, 55)), resultColor, true)
	

