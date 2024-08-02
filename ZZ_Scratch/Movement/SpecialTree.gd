extends Node2D


func set_detected(is_detected: bool) -> void:
	print("special tree detection state: " + str(is_detected))
	if is_detected:
		show()
	else:
		hide()
