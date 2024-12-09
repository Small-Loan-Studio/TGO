class_name SwitchConfig
extends Node2D

signal triggered(id: String, state: bool)
signal failed_trigger(id: String, reason: Enums.TriggerFailure)

## Checked as part of an evaluation if some actor can press a switch
@export var conditions: Array[TriggerCondition] = []

## If set a switch may only be triggered once and will not be released when
## the trigger actors are removed. May be reset only via [reset].
@export var single_fire: bool = false

## If set only an actor with one of the listed IDs can activate a switch.
@export var id_mask: Array[String] = []

## A list of effects to perform when a switch is pressed
@export var on_pressed_effects: Array[Effect] = []
## A list of effects to perform when a switch is released
@export var on_released_effects: Array[Effect] = []

## This is set when the switch has been pressed by one or more actors
var is_pressed: bool = false

@onready var _switch: Switch = $Switch


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_switch.set_config(self)


## Reset switch state. That means:
##    a. clears the activation stack
##    b. sets is_pressed to false.
## Does not emit triggered(false) or activate on_released_effects chain. If a
## switch was previously single_fire it remains single_fire after a reset.
func reset() -> void:
	_switch._activation_stack.clear()
	is_pressed = false
