extends Camera2D

var zoomspeed: float = 2
var zoommargin: float = 0.1

var zoom_min: float = 0.1
var zoom_max: float = 4.0

var zoompos: Vector2 = Vector2()
var zoomfactor: float = 1.0

func _process(_delta: float) -> void:
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed)

	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)

func _input(event: InputEvent) -> void:
	if abs(zoompos.x - get_global_mouse_position().x) > zoommargin:
		zoomfactor = 1.0
	if abs(zoompos.y - get_global_mouse_position().y) > zoommargin:
		zoomfactor = 1.0

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoomfactor += 0.01
				zoompos = get_global_mouse_position()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoomfactor -= 0.01
				zoompos = get_global_mouse_position()
