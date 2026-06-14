extends Node2D

func _draw():
	# Draw a dark gray background covering a large area
	# Adjust the rect size (-5000, -5000, 10000, 10000) to be larger than your level
	draw_rect(Rect2(-5000, -5000, 10000, 10000), Color(0.2, 0.2, 0.2))
	
	# Optional: Draw a grid to see movement clearly
	var step = 100
	for x in range(-5000, 5000, step):
		draw_line(Vector2(x, -5000), Vector2(x, 5000), Color(0.3, 0.3, 0.3), 2)
	for y in range(-5000, 5000, step):
		draw_line(Vector2(-5000, y), Vector2(5000, y), Color(0.3, 0.3, 0.3), 2)

func _ready():
	# Force the _draw function to run
	queue_redraw()
