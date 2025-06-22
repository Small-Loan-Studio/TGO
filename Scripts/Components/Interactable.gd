@tool
## Node that can be attached to make something an interactable object.
## When interaction is triggered (manual or automatic) the list of attached
## actions will be run and then the triggered signal will be emitted. If no
## effects are attached to the action the triggered signal will still be
## emitted.
##
## Must be attached to scenes that contain a LevelBase as a ancestor.
class_name Interactable
extends Area2D

## Fires when an actor indicates they wish to interact with this object.
## Passed the triggering Character
signal triggered(actor: Character)

const InteractPanelScene: PackedScene = preload(
	"res://Scenes/Components/interacting/interact_panel.tscn"
)

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
##
## TODO: This is a load bearing mistake. If an interactable gets embedded in
## another scene then changes to the action_map get mirrored to all instances
## of the embedding scene. We need to replace this with a composition solution:
##   1. For each action type create a node that contains an Array[Effect]
##   2. construct the action_map in _ready based on the Node's children
##   3. remove action_map and burn Godot alive
## TODOTODO: file issue to track this
@export var action_map: Dictionary = {}

@export var _display_hook: Sprite2D

var examine: InteractPanel:
	get:
		return _examine_scene
var interact: InteractPanel:
	get:
		return _interact_scene

var _examine_scene: InteractPanel = null
var _interact_scene: InteractPanel = null

# TODO: add conditions

## Tracks the level that the action is taking place in
var _cur_level: LevelBase


func _ready() -> void:
	_cur_level = Utils.get_level_parent(self)


func activate() -> void:
	var player: Character = Driver.instance().player
	var pmid: Vector2 = player.position
	var tmid: Vector2 = self.owner.position
	var tsize := Vector2.ZERO
	if self._display_hook != null:
		tsize = _display_hook.get_rect().position
	else:
		tsize = self.owner.size
	tmid.x -= tsize.x / 2
	tmid.y -= tsize.y / 2

	var examine_actions: Array = action_map.keys().filter(
		func(e: Enums.ActionVerb) -> bool: return e == Enums.ActionVerb.EXAMINE
	)
	var interact_actions: Array = action_map.keys().filter(
		func(e: Enums.ActionVerb) -> bool: return e != Enums.ActionVerb.EXAMINE
	)

	_examine_scene = InteractPanelScene.instantiate()
	_examine_scene.actions.assign(examine_actions)
	_examine_scene.input = Enums.InputAction.SECONDARY
	_examine_scene.target = self.owner
	_examine_scene.target_size = tsize

	_interact_scene = InteractPanelScene.instantiate()
	_interact_scene.actions.assign(interact_actions)
	_interact_scene.input = Enums.InputAction.DEFAULT
	_interact_scene.target = self.owner
	_interact_scene.target_size = tsize

	if (tmid - pmid).x < 0:
		_examine_scene.layout = InteractOption.LAYOUT_LEFT
		_interact_scene.layout = InteractOption.LAYOUT_LEFT
		_interact_scene.placement = InteractPanel.PLACEMENT_WEST
	else:
		_examine_scene.layout = InteractOption.LAYOUT_RIGHT
		_interact_scene.layout = InteractOption.LAYOUT_RIGHT
		_interact_scene.placement = InteractPanel.PLACEMENT_EAST
	if (tmid - pmid).y < 0:
		_examine_scene.placement = InteractPanel.PLACEMENT_NORTH
	else:
		_examine_scene.placement = InteractPanel.PLACEMENT_SOUTH

	if len(examine_actions) > 0:
		_examine_scene.present()
	if len(interact_actions) > 0:
		_interact_scene.present()


func deactivate() -> void:
	if _examine_scene:
		_examine_scene.queue_free()
		_examine_scene = null
	if _interact_scene:
		_interact_scene.queue_free()
		_interact_scene = null


func trigger(actor: Character, action: Enums.ActionVerb = default_verb) -> void:
	var action_list: Array[Effect] = []
	if action_map.has(action):
		action_list.assign(action_map[action])

	for a: Effect in action_list:
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
	var props: Array[Dictionary] = []

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
			print("action_map[%s] = %s" % [Enums.action_verb_name(verb), _val])
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
