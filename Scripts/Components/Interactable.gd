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

## Changing this impacts what the game toast will be when the player
## has a chance to interact with the interactable object.
@export var default_verb: Enums.ActionVerb = Enums.ActionVerb.DEFAULT:
	get:
		return default_verb
	set(value):
		default_verb = value
		# TODO: this doesn't seem to reliably trigger reevaluation?
		update_configuration_warnings()

## Maps action type to the effect when that action is taken. Note that
## Some combinations won't make sense, e.g., Adding a Grab action to something
## only operates correctly on a MoveableBlock.
##
##   Type: Map[Enums.ActionVerb, Array[Effect]]
@export var action_map: Dictionary = {}

# TODO: add conditions

## A set of actions to be taken when this interactable gets triggered. Will be
## evaluated before the signal is emitted.
##
## USAGE OF THIS IS DEPRECATED
var actions: Array[Effect]:
	get:
		if len(actions) > 0:
			action_map[default_verb] = actions
		if action_map.has(default_verb):
			return action_map[default_verb]
		return []
	set(value):
		if len(value) > 0:
			action_map[default_verb] = value
		printerr("Should not be setting actions")
		print_stack()
		actions = value

## Tracks the level that the action is taking place in
var _cur_level: LevelBase


func _ready() -> void:
	_cur_level = Utils.get_level_parent(self)
	if Engine.is_editor_hint():
		if len(actions) > 0:
			action_map[default_verb] = actions
			actions = []


func trigger(actor: Character, action: Enums.ActionVerb = default_verb) -> void:
	if !action_map.has(action):
		return

	for a: Effect in action_map[action]:
		if a == null:
			continue
		a.parent = self
		a.act(actor.id, _cur_level)
	triggered.emit(actor)


func verb_name() -> String:
	return Enums.action_verb_name(default_verb)


# TODO: Check if Collision layer is set properly -- if we do this make sure to
# add @tool annotation
func _get_configuration_warnings() -> PackedStringArray:
	var errs := []
	# TODO: Don't use a magic number here; switch to named layers, c.f.
	#     https://gamedev.stackexchange.com/a/185955
	if !(collision_layer & 2):
		errs.push_back("Collision layer set should be set to 2 by default")

	if (
		!action_map.has(default_verb)
		|| len(action_map[default_verb].filter(func(e: Effect) -> bool: return e != null)) == 0
	):
		errs.push_back(
			"No actions defined for default_verb " + Enums.action_verb_name(default_verb)
		)
	return errs


## Overrides the properties that an interactable reports as available for edit.
func _get_property_list() -> Array[Dictionary]:
	# this should keep "actions" loading and persisting to a .tscn while hiding
	# it from the inspector UI
	var props: Array[Dictionary] = [
		{
			"name": "actions",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_ARRAY_TYPE,
			"hint_string": "24/17:Effect",
			"usage": PROPERTY_USAGE_STORAGE,
		}
	]

	# Walk the set of actions that have entries in the action_map and generate
	# synthetic properties for editing since the inspector-default editor for
	# dictionaries is shit / doesn't understand type constraints; we handle
	# assignment for these via _set
	for k: Enums.ActionVerb in action_map.keys():
		(
			props
			. append(
				{
					"name": "%s_effects" % [Enums.action_verb_name(k)],
					"type": TYPE_ARRAY,
					"hint": PROPERTY_HINT_ARRAY_TYPE,
					"hint_string": "24/17:Effect",
					"usage": PROPERTY_USAGE_EDITOR,
				}
			)
		)
	return props


## Callback used by _set to clear a verb from the action_map
func _unset_verb(verb: Enums.ActionVerb) -> void:
	action_map.erase(verb)
	property_list_changed.emit()


## Gets called when a property is set, if changing one of the synthetic props
## translates that into updating the action_map.
func _set(prop: StringName, _val: Variant) -> bool:
	if prop.ends_with("_effects"):
		var parts := prop.split("_")
		var verb := Enums.action_verb_from_str(parts[0])

		if action_map.has(verb) and len(_val) == 0:
			# this branch runs when we had a verb and we remove the last element;
			# in that case just remove the verb entirely
			action_map[verb] = _val
			_unset_verb.bind(verb).call_deferred()
		else:
			action_map[verb] = _val
		return true
	return false


## Gets called when a read is issued to a property, if called on one of the
## synthetic props translates into pulling data from the action_map
func _get(prop: StringName) -> Variant:
	if prop.ends_with("_effects"):
		var parts := prop.split("_")
		var verb := Enums.action_verb_from_str(parts[0])
		if action_map.has(verb):
			return action_map[verb]

	return null
