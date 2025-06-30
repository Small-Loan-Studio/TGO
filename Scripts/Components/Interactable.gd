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

## Fires when an actor indicates they wish to primary with this object.
## Passed the triggering Character
signal triggered(actor: Character)

const InteractPanelScene: PackedScene = preload(
	"res://Scenes/Components/interacting/interact_panel.tscn"
)

## If set this will trigger automatically when a Character looking for
## interactables enters the area. This makes the interaction *not* manually
## triggerable through the "primary" action
@export var automatic: bool = false

## Changing this impacts what the game toast will be when the player
## has a chance to primary with the interactable object.
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

@export var secondary_action_order: Array[Enums.ActionVerb] = []

@export var _display_hook: Sprite2D

var secondary: InteractPanel:
	get:
		return _secondary_scene
var primary: InteractPanel:
	get:
		return _primary_scene

var action_count: int:
	get:
		return action_map.size()

var _primary_scene: InteractPanel = null
var _secondary_scene: InteractPanel = null

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

	var default_action: Array = action_map.keys().filter(
		func(e: Enums.ActionVerb) -> bool: return e == default_verb
	)

	var proto_secondary_actions: Array = action_map.keys().filter(
		func(e: Enums.ActionVerb) -> bool: return e != default_verb
	)

	var secondary_actions: Array = []
	var seen := {}
	for ele in secondary_action_order:
		if action_map.has(ele) && ele != default_verb:
			secondary_actions.append(ele)
			seen[ele] = true
	for rem: Enums.ActionVerb in proto_secondary_actions:
		if !seen.has(rem):
			secondary_actions.append(rem)

	_primary_scene = InteractPanelScene.instantiate()
	_primary_scene.actions.assign(default_action)
	_primary_scene.input = Enums.InputAction.DEFAULT
	_primary_scene.target = self.owner
	_primary_scene.target_size = tsize

	_secondary_scene = InteractPanelScene.instantiate()
	_secondary_scene.actions.assign(secondary_actions)
	_secondary_scene.input = Enums.InputAction.SECONDARY
	_secondary_scene.target = self.owner
	_secondary_scene.target_size = tsize

	if (tmid - pmid).x < 0:
		_primary_scene.layout = InteractOption.LAYOUT_LEFT
		_secondary_scene.layout = InteractOption.LAYOUT_LEFT
		_secondary_scene.placement = InteractPanel.PLACEMENT_WEST
	else:
		_primary_scene.layout = InteractOption.LAYOUT_RIGHT
		_secondary_scene.layout = InteractOption.LAYOUT_RIGHT
		_secondary_scene.placement = InteractPanel.PLACEMENT_EAST
	if (tmid - pmid).y < 0:
		_primary_scene.placement = InteractPanel.PLACEMENT_NORTH
	else:
		_primary_scene.placement = InteractPanel.PLACEMENT_SOUTH

	if len(default_action) > 0:
		_primary_scene.present()

	if len(secondary_actions) > 0:
		_secondary_scene.present()


func deactivate() -> void:
	if _primary_scene:
		_primary_scene.queue_free()
		_primary_scene = null
	if _secondary_scene:
		_secondary_scene.queue_free()
		_secondary_scene = null


func trigger(actor: Character, action: Enums.ActionVerb = default_verb) -> void:
	print("triggering: %s with %s" % [get_parent().name, Enums.action_verb_name(action)])
	var action_list: Array[Effect] = []
	if action_map.has(action):
		action_list.assign(action_map[action])

	for a: Effect in action_list:
		if a == null:
			continue
		a.parent = self
		await a.act(actor.id, _cur_level)
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
