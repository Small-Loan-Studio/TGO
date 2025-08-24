class_name ItemDisplayRect
extends Container

const Scene: PackedScene = preload("res://Scenes/Menu/ItemDisplayRect.tscn")

var _idx: int
var _item: Item

# can't use onready because set up the rects _then_ add them to the scene

var _icon: TextureRect:
	get:
		return $ItemTexture

var _selected: TextureRect:
	get:
		return $ItemFocus

static func mk(idx: int) -> ItemDisplayRect:
	var scn := ItemDisplayRect.Scene.instantiate() as ItemDisplayRect
	scn._idx = idx
	return scn

func set_item(new_item: Item) -> void:
	_item = new_item
	if _item == null:
		_icon.visible = false
		return

	_icon.texture = _item.icon
	_icon.visible = true

func item() -> Item:
	return _item


func _ready() -> void:
	print("ItemDisplayRect._ready")

func focus() -> void:
	_selected.visible = true

func blur() -> void:
	_selected.visible = false
