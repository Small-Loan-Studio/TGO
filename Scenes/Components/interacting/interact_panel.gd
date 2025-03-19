# The action panel is the system for presenting actions to a user within the
# game. It works by taking a list of actions to present, the input that
# controls them and a target to present them on, therefore the target must have
# a size and a position.
#
# In addition to the above it is also possible to change the positioning and
# styling.

class_name InteractPanel
extends Container

enum { PLACEMENT_NORTH, PLACEMENT_SOUTH, PLACEMENT_EAST, PLACEMENT_WEST }

const InteractMenuScene: PackedScene = preload("./interact_menu.tscn")
const InteractOptionScene: PackedScene = preload("./interact_option.tscn")

var placement := PLACEMENT_EAST

var actions: Array[Enums.ActionVerb]
# NOTE: Setting this is not ideal as we only allow `EXAMINE` or `INTERACT` but
# this is sufficient for now.
var input: Enums.InputAction
var layout := InteractOption.LAYOUT_RIGHT
var selected: Enums.ActionVerb:
	get:
		if _menu:
			if _selected == 0:
				return Enums.ActionVerb.DEFAULT
			return actions[_selected - 1]
		return actions[_selected]
var target: Node2D

var _expanded: bool = false
var _menu: InteractMenu = null
var _option: InteractOption = null
var _selected: int = 0

@onready var _container := $Container

## Public


# Dismiss the action panel.
func dismiss() -> void:
	self.queue_free()


# Present the action panel around the set target.
func present() -> void:
	target.add_child(self)


# Remove any selection
func blur() -> void:
	if _menu:
		for option in _menu.options:
			option.blur()
	_option.blur()
	_selected = 0


# Focus the given verb
func focus(verb: Enums.ActionVerb) -> void:
	if _menu:
		for i in range(actions.size()):
			var action := actions[i]
			var option := _menu.options[i]
			if action == verb:
				option.focus()
				_selected = i + 1
			else:
				option.blur()
	else:
		_option.focus()


# Move focus to the next action if applicable
func next() -> void:
	if _menu:
		if _selected < actions.size():
			_selected += 1
		_option.blur()
		var options := self._menu.options
		for i in range(actions.size()):
			if i == _selected - 1:
				options[i].focus()
			else:
				options[i].blur()


# Move focus to the previous action if applicable
func previous() -> void:
	if _menu:
		if _selected > 0:
			_selected -= 1
		if _selected == 0:
			_option.focus()
		var options := self._menu.options
		for i in range(actions.size()):
			if i == _selected - 1:
				options[i].focus()
			else:
				options[i].blur()


# Toggle the menu if applicable
func toggle() -> void:
	if _menu:
		_option.toggle_chevron()
		if _expanded:
			_menu.collapse()
			_option.focus()
		else:
			_menu.expand()
			_option.blur()
		_expanded = !_expanded


## Private


func _on_menu_closed() -> void:
	_option.label = _get_label()


func _on_menu_opened() -> void:
	_option.label = "Close"


func _get_label() -> String:
	if actions.size() == 1:
		return Enums.action_verb_name(actions[0])
	match input:
		Enums.InputAction.EXAMINE:
			return Enums.input_action_name(input)
		Enums.InputAction.INTERACT:
			return Enums.input_action_name(input)
		_:
			assert(false, "ERROR: Unsupported input action selected.")
			return ""


func _get_symbol() -> Image:
	match input:
		Enums.InputAction.EXAMINE:
			return Enums.input_action_symbol(input)
		Enums.InputAction.INTERACT:
			return Enums.input_action_symbol(input)
		_:
			assert(false, "ERROR: Unsupported input action selected.")
			return null


## Override


func _ready() -> void:
	_option = InteractOptionScene.instantiate()
	_option.label = _get_label()
	_option.layout = layout
	_option.symbol = _get_symbol()

	if actions.size() > 1:
		_option.expandable = true
		_menu = InteractMenuScene.instantiate()
		_menu.actions.assign(actions)
		_menu.layout = layout
		_menu.closed.connect(_on_menu_closed)
		_menu.opened.connect(_on_menu_opened)
	else:
		_option.expandable = false
	_container.add_child(_option)
	if _menu:
		_container.add_child(_menu)

	var tsize: Vector2 = target.size
	# NOTE: The current button size is 42x42 so if the target is smaller than
	# this we need to virtually enlarge it.
	if tsize.x < 42:
		tsize.x = 42
	if tsize.y < 42:
		tsize.y = 42

	match placement:
		PLACEMENT_NORTH:
			self.position.y -= tsize.y + self._option.size.y + 24
		PLACEMENT_SOUTH:
			self.position.y += 24
		PLACEMENT_EAST:
			self.position.x += tsize.x + 12
			self.position.y -= tsize.y
		PLACEMENT_WEST:
			self.position.x -= tsize.x + 12
			self.position.y -= tsize.y

	_option.focus()
