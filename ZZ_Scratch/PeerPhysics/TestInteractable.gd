extends RigidBody2D

func on_trigger(area: Area2D) -> void:
	print('triggered by ' + area.name + ' / ' + area.get_parent().name)