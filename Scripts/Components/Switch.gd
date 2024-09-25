class_name Switch
extends Area2D

signal triggered(state: bool)
signal failed_trigger(reason: String)

var is_pressed: bool = false

@export var conditions: Array[TriggerCondition] = []
@export var single_fire: bool = false
@export var id_mask: Array[String] = []
@export var has_triggered: bool = false
@export var on_pressed_effects: Array[Effect] = []
@export var on_released_effects: Array[Effect] = []

var _activation_stack: Array[String]

func _ready() -> void:
	print('Switch %s._ready()' % [ name])

func _on_enter(area: Area2D) -> void:
	print("_on_enter:", area)


func _on_enter_body(body: Node2D) -> void:
	if "id" in body:
		_on_enter_id(body.id)
	else:
		printerr(body.name, "body entered that has no id, likely misconfiguration")


func _on_exit(area: Area2D) -> void:
	print("_on_exit:", area)


func _on_exit_body(body: Node2D) -> void:
	if "id" in body:
		_on_exit_id(body.id)
	else:
		printerr(body.name, "body exited that has no id, likely misconfiguration")


func _on_enter_id(id: String) -> void:
	print("_on_enter_id(%s)" % [id])


func _on_exit_id(id: String) -> void:
	print("_on_exit_id(%s)" % [id])