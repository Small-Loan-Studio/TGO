extends Area2D

signal detected(is_detected: bool)

var _override_detection: bool = false

func set_detected(is_detected: bool) -> void:
	if detected.get_connections().size() > 0:
		detected.emit(is_detected)
	else:
		# print('default set_detected(' + str(is_detected) + ')')
		if is_detected:
			get_parent().show()
		else:
			get_parent().hide()