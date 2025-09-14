class_name ItemSelectControl
extends PanelContainer

const SCENE = "res://Scenes/Menu/ItemSelectControl.tscn"

signal select(selected: Item)

@export var item_width: int = 32

var _item_grid: InventoryContainer:
	get:
		return %ItemGrid

var _status_bar: ItemSelectBar:
	get:
		return %ItemSelectBar


static func mk(x: int, y: int, ctrl: ControllerBase, items: Array[Item]) -> ItemSelectControl:
	var scn := load(SCENE).instantiate() as ItemSelectControl
	scn.setup(x, y, ctrl, items, [])
	return scn


func setup(
	x: int,
	y: int,
	ctrl: ControllerBase,
	items: Array[Item],
	acceptable_directions: Array[Enums.InputAction],
) -> void:
	if acceptable_directions.size() == 0:
		acceptable_directions = [
			Enums.InputAction.LEFT,
			Enums.InputAction.RIGHT,
			Enums.InputAction.UP,
			Enums.InputAction.DOWN,
		]
	self._item_grid.setup(x, y, ctrl, items, acceptable_directions)


func _ready() -> void:
	print("ItemSelectControl._ready @ %d" % [item_width])

func set_item(item: Item) -> void:
	if item == null:
		_status_bar.text = ""
		return
	
	_status_bar.text = item.name


var _last_item: String = ""

func _process(_delta: float) -> void:
	var item: Item =_item_grid.current_item()
	if item != null:
		var cur_id := item.id

		if _last_item == cur_id:
			return

		_last_item = cur_id
		set_item(item)
