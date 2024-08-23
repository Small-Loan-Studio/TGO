class_name CharacterTarget
extends RefCounted


var _typ: Enums.TargetType

var _interactable: Interactable = null
var _block: MoveableBlock = null


static func none() -> CharacterTarget:
	var t := CharacterTarget.new()
	t._typ = Enums.TargetType.NONE
	return t


func reset() -> void:
	_typ = Enums.TargetType.NONE
	_interactable = null
	_block = null


func set_interactable(i: Interactable) -> void:
	reset()
	_typ = Enums.TargetType.INTERACTABLE
	_interactable = i


func set_moveable_block(m: MoveableBlock) -> void:
	reset()
	_typ = Enums.TargetType.MOVEABLE_BLOCK
	_block = m


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


func update(v: Variant) -> void:
	if v is Interactable:
		print("set interactable: " + str(v))
		set_interactable(v as Interactable)
	elif v is MoveableBlock:
		print("set moveable block: " + str(v))
		set_moveable_block(v as MoveableBlock)
	else:
		printerr("Attempting to set character target to invalid type: " + str(v))
		reset()


func _to_string() -> String:
	return "typ: %s / _interactable: %s / _block: %s" % [_typ, _interactable, _block]
