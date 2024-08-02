## Node that can be attached to make something an interactable object.
## When interaction is triggered (manual or automatic) the list of attached
## actions will be run and then the triggered signal will be emitted.
class_name Interactable
extends Area2D

## Fires when an actor indicates they wish to interact with this object.
## Passed the triggering Character
signal triggered(actor: Character)

## If set this will trigger automatically when a Character looking for
## interactables enters the area. This makes the interaction *not* manually
## triggerable through the "interact" action
@export var automatic: bool = false

## A set of actions to be taken when this interactable gets triggered. Will be
## evaluated before the signal is emitted.
@export var actions: Array[InteractableAction]


func trigger(actor: Character) -> void:
	for a in actions:
		a.parent = self
		a.act(actor)
	triggered.emit(actor)
