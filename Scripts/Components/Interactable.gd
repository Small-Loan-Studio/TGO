class_name Interactable
extends Area2D

## Fires when an actor indicates they wish to interact with this object.
## Passed the triggering Area2D for now since we don't have a generalized
## actor (plausibly we could use Character but I don't trust that decision
## yet)
signal triggered(actor: Area2D)