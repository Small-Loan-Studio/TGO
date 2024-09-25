class_name Switch
extends Area2D

# enum TriggerFailue { ID_MASK, CONDITIONS }

signal triggered(state: bool)
signal failed_trigger(reason: String)

## This is set when the switch has been pressed by one or more actors
var is_pressed: bool = false

## Checked as part of an evaluation if some actor can press a switch
@export var conditions: Array[TriggerCondition] = []

## If set a switch may only be triggered once and will not be released when
## the trigger actors are removed. May be reset only via [reset].
@export var single_fire: bool = false

## If set only an actor with one of the listed IDs can activate a switch.
@export var id_mask: Array[String] = []

@export var on_pressed_effects: Array[Effect] = []
@export var on_released_effects: Array[Effect] = []

## Tracks the full set of ids that are present in this switch area and have
## triggered an activation (or can keep it activated)
var _activation_stack: Array[String]

## Tracks the level that the action is taking place in
var _cur_level: LevelBase

func _ready() -> void:
	print('Switch %s._ready()' % [ name])

	var ref: Node = self
	while not (ref is LevelBase):
		ref = ref.get_parent()
		if ref == null:
			printerr("Switch: 2did not find a LevelBase parent for %s" % [name])
			break
	if ref != null:
		_cur_level = ref


## Reset switch state. That means:
##    a. clears the activation stack
##    b. sets is_pressed to false.
## Does not emit triggered(false) or activate on_released_effects chain. If a
## switch was previously single_fire it remains single_fire after a reset.
func reset() -> void:
	_activation_stack.clear()
	is_pressed = false

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
	if id_mask != null && id_mask.size() > 0:
		if !(id in id_mask):
			failed_trigger.emit("TriggerFailue.ID_MASK")
			return

	if id in _activation_stack:
		return

	print("TODO: check conditions")

	_activation_stack.push_back(id)

	if !is_pressed:
		_do_press()


func _on_exit_id(id: String) -> void:
	var idx := _activation_stack.find(id)
	if idx == -1:
		return
	_activation_stack.remove_at(idx)

	if _activation_stack.size() == 0:
		_do_release()


## Does the work of actually setting the switch state to pressed. It updates
## internal state, emits triggered signals, and fires any configured effects.
## If a switch is already pressed bails without any changes / side effects.
func _do_press() -> void:
	if is_pressed:
		return
	is_pressed = true
	print("_do_press")
	triggered.emit(true)
	for e in on_pressed_effects:
		e.act(null, _cur_level)


## Does the work of deactivating the switch. That is it updates internal state,
## emits a triggered signal, and fires any configured effects. If a switch is
## single_fire then it does not make any changes.
func _do_release() -> void:
	print("_do_release")
	if single_fire:
		print("   ...but single_fire")
		return

	is_pressed = false
	triggered.emit(false)
	for e in on_released_effects:
		e.act(null, _cur_level)