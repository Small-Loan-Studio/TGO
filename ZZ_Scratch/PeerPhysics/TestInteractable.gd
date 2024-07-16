extends RigidBody2D

func on_trigger(actor: Character) -> void:
	print('triggered by ' + actor.name + ' / ' + actor.get_parent().name)