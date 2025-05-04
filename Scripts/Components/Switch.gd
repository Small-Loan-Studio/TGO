## A reactive area that can be placed in a level to monitor for activation
## under specified conditions. In order to activate a switch you must move
## an Area2D or Physics Body in the "switch actor" collision layer into the
## area.
##
## In addition to the raw ability to detect Switch Actors we can limit
## activation in two ways:
##   1. id_mask is an Array[String] that filters out any activations not
##      resulting from an area/body with an id in this set
##   2. conditions is an Array[TriggerCondition] that filters out any
##      activations if conditions are not met
##
## When activated a Switch will first emit the [triggered] signal and then
## perform any configured on_press_effects.
##
## When the last activating actor leaves the space a switch may release if
## [single_fire] is not set. In that case it first emits triggered and then
## performs any configured on_release_effects.
##
## When an actor enters the switch space and fails to trigger an activation
## for an unpressed switch failed_trigger is fired.
class_name Switch
extends Area2D

## Tracks the full set of ids that are present in this switch area and have
## triggered an activation (or can keep it activated)
var _activation_stack: Array[String]

## A list of callbacks that should be made for switches on-release
var _waiting_callbacks: Array[Callable]


## Tracks the level that the action is taking place in
var _cur_level: LevelBase

var _config: SwitchConfig


func _ready() -> void:
	_cur_level = Utils.get_level_parent(self)


func set_config(cfg: SwitchConfig) -> void:
	_config = cfg


func _on_enter(area: Area2D) -> void:
	if "id" in area.get_parent():
		_on_enter_id(area.get_parent().id)
	else:
		printerr(area.name, "parent has no ID, likely misconfiguration")


func _on_enter_body(body: Node2D) -> void:
	if "id" in body:
		_on_enter_id(body.id)
	else:
		printerr(body.name, "body entered that has no ID, likely misconfiguration")


func _on_exit(area: Area2D) -> void:
	if "id" in area.get_parent():
		_on_exit_id(area.get_parent().id)
	else:
		printerr(area.name, "parent has no ID, likely misconfiguration")


func _on_exit_body(body: Node2D) -> void:
	if "id" in body:
		_on_exit_id(body.id)
	else:
		printerr(body.name, "body exited that has no id, likely misconfiguration")


func _on_enter_id(id: String) -> void:
	if _config.id_mask != null && _config.id_mask.size() > 0:
		if !(id in _config.id_mask):
			# Because the switch is already pressed this activation didn't really
			# fail to press it so much it didn't get into the activation stack.
			if !_config.is_pressed:
				_config.failed_trigger.emit(id, Enums.TriggerFailure.ID_MASK)
			return

	if id in _activation_stack:
		printerr("%s: ID %s attempting to activate but already in stack" % [name, id])
		return

	for c in _config.conditions:
		if !c.evaluate(id):
			_config.failed_trigger.emit(id, Enums.TriggerFailure.CONDITIONS)
			return

	_activation_stack.push_back(id)

	if !_config.is_pressed:
		_do_press(id)


func _on_exit_id(id: String) -> void:
	var idx := _activation_stack.find(id)
	if idx == -1:
		return
	_activation_stack.remove_at(idx)

	if _activation_stack.size() == 0:
		_do_release(id)


## Does the work of actually setting the switch state to pressed. It updates
## internal state, emits triggered signals, and fires any configured effects.
## If a switch is already pressed bails without any changes / side effects.
func _do_press(id: String) -> void:
	if _config.is_pressed:
		return
	_config.is_pressed = true
	_config.triggered.emit(id, true)
	for e in _config.on_pressed_effects:
		var ctx: Variant = e.act(id, _cur_level)
		if ctx != null:
			_waiting_callbacks.push_back(func() -> void: e.terminal_callback(ctx))


## Does the work of deactivating the switch. That is it updates internal state,
## emits a triggered signal, and fires any configured effects and waiting callbacks.
## If a switch is single_fire then it does not make any changes.
func _do_release(id: String) -> void:
	if _config.single_fire:
		return

	_config.is_pressed = false
	_config.triggered.emit(id, false)
	for e in _config.on_released_effects:
		e.act(id, _cur_level)

	for cb in _waiting_callbacks:
		cb.call()
	_waiting_callbacks.clear()
