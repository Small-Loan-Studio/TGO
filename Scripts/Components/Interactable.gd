class_name Interactable
extends Area2D

## Fires when an actor indicates they wish to interact with this object.
## Passed the triggering Character
signal triggered(actor: Character)

## If set this will trigger automatically when a Character looking for
## interactables enters the area. This makes the interaction *not* manually
## triggerable through the "interact" action
@export var automatic: bool = false