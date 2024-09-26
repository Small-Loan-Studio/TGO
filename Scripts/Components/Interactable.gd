@tool
## Node that can be attached to make something an interactable object.
## When interaction is triggered (manual or automatic) the list of attached
## actions will be run and then the triggered signal will be emitted.
##
## Must be attached to scenes that contain a LevelBase as a ancestor.
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
@export var actions: Array[Effect]

## Changing this impacts what the game toast will be when the player
## has a chance to interact with the interactable object.
@export var action_verb: Enums.ActionVerb = Enums.ActionVerb.DEFAULT

# TODO: add conditions

## Tracks the level that the action is taking place in
var _cur_level: LevelBase


func _ready() -> void:
	_cur_level = Utils.get_level_parent(self)
	print("Interactable._cur_level: ", _cur_level)

func trigger(actor: Character) -> void:
	for a in actions:
		if a == null:
			continue
		a.parent = self
		a.act(actor.id, _cur_level)
	triggered.emit(actor)


func verb_name() -> String:
	return Enums.action_verb_name(action_verb)


# TODO: Check if Collision layer is set properly -- if we do this make sure to
# add @tool annotation
func _get_configuration_warnings() -> PackedStringArray:
	# TODO: Don't use a magic number here; switch to named layers, c.f.
	#     https://gamedev.stackexchange.com/a/185955
	if collision_layer | 2:
		return ["Collision layer set should be set to 2 by default"]
	return []
