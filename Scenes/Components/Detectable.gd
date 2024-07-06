extends Area2D

@export var _parent: Node2D = null

var _override_detection: bool = false

func _ready() -> void:
	if _parent == null:
		_parent = get_parent()
	_override_detection = _parent.has_method('set_detected')

func set_detected(is_detected: bool) -> void:
	if _override_detection:
		_parent.set_detected(is_detected)
	else:
		# print('default set_detected(' + str(is_detected) + ')')
		if is_detected:
			_parent.show()
		else:
			_parent.hide()