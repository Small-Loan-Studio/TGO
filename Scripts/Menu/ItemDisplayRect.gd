class_name ItemDisplayRect
extends Control

const Scene: PackedScene = preload("res://Scenes/Menu/ItemDisplayRect.tscn")

var _idx: int
var _item: Item

static func mk(idx: int) -> ItemDisplayRect:
	var scn := ItemDisplayRect.Scene.instantiate() as ItemDisplayRect
	scn._idx = idx
	return scn

func set_item(item: Item) -> void:
	_item = item
	if _item != null:
		print("%d <- %s" % [_idx, _item.id])
	else:
		print("%d <- null" % [_idx])