class_name CharacterTarget
extends RefCounted

signal target_changed

var _typ: Enums.TargetType

var _interactable: Interactable = null
var _block: MoveableBlock = null


static func none() -> CharacterTarget:
	var t := CharacterTarget.new()
	t._typ = Enums.TargetType.NONE
	return t


func _clear() -> void:
	_typ = Enums.TargetType.NONE
	_interactable = null
	_block = null


## clear the target, emits a target changed signal if a target was previously set
func reset() -> void:
	var was_set := is_set()
	_clear()

	if was_set:
		target_changed.emit()


## sets an interactable as the current target; if this is a new target emits
## a target changed signal
func set_interactable(i: Interactable) -> void:
	if _interactable == i:
		return

	_clear()
	_typ = Enums.TargetType.INTERACTABLE
	_interactable = i
	target_changed.emit()


## sets a moveable block as target; if this is a new target emits a target
## changed signal
func set_moveable_block(m: MoveableBlock) -> void:
	if _block == m:
		return

	_clear()
	_typ = Enums.TargetType.MOVEABLE_BLOCK
	_block = m
	target_changed.emit()


func get_type() -> Enums.TargetType:
	return _typ


func is_set() -> bool:
	return _typ != Enums.TargetType.NONE


func is_interactable() -> bool:
	return _typ == Enums.TargetType.INTERACTABLE


func is_moveable_block() -> bool:
	return _typ == Enums.TargetType.MOVEABLE_BLOCK


func get_interactable() -> Interactable:
	return _interactable


func get_moveable_block() -> MoveableBlock:
	return _block


## generic/untyped method that can
func update(v: Variant) -> void:
	if v is Interactable:
		set_interactable(v as Interactable)
	elif v is MoveableBlock:
		set_moveable_block(v as MoveableBlock)
	else:
		printerr("Attempting to set character target to invalid type: " + str(v))
		reset()


func _to_string() -> String:
	return "typ: %s / _interactable: %s / _block: %s" % [_typ, _interactable, _block]
