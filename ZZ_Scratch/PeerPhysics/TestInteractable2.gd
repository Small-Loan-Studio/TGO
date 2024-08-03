extends RigidBody2D

@export var destination: Node2D


func on_trigger(actor: Character) -> void:
	print("triggered by " + actor.name)
	# could also start dialogue, do an item pickup, whatever
	# many common ones we'll get to be configurable from the UI
	actor.global_position = destination.global_position
