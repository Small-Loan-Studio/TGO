class_name DebugInventory
extends HBoxContainer

const ITEM_PATH = "res://Scripts/Resources/Items"

var _item_stack: ItemStack
var _item_id: int
var _quantity_id: int = -1
var _item: Item

@onready var _inventory: Inventory
@onready var _item_picker: OptionButton = $ItemPicker
@onready var _quantity_picker: OptionButton = $QuantityPicker
@onready var _item_dict: Dictionary = {}


func update_inv_options() -> void:
	#Loads configured items into the ItemPicker list
	_item_dict.clear()
	_item_picker.clear()

	var dir := DirAccess.open(ITEM_PATH)
	if dir == null:
		printerr("Failed to open item resource path:", DirAccess.get_open_error())
		return
	dir.list_dir_begin()
	var item_file := dir.get_next()
	# walks the Item resource path and gets the configured resources
	while item_file != "":
		if item_file.ends_with(".tres"):
			var config := ResourceLoader.load(ITEM_PATH + "/" + item_file) as Item
			if config != null:
				var key := config.id
				_item_dict[key] = config
				if _item_picker:
					_item_picker.add_item(key)
		item_file = dir.get_next()


func setup(inv: Inventory) -> void:
	_inventory = inv
	update_inv_options()


func remove_item() -> void:
	_item_id = _item_picker.get_selected_id()
	_quantity_id = _quantity_picker.get_selected_id()
	if _item_id == -1 or _quantity_id == -1:
		printerr("No item or quantity selected")
		return
	_inventory.remove_by_id(
		_item_picker.get_item_text(_item_id), int(_quantity_picker.get_item_text(_quantity_id))
	)


func add_item() -> void:
	_item_id = _item_picker.get_selected_id()
	_quantity_id = _quantity_picker.get_selected_id()
	if _item_id == -1 or _quantity_id == -1:
		printerr("No item or quantity selected")
		return
	_item = _item_dict[_item_picker.get_item_text(_item_id)]
	if int(_quantity_picker.get_item_text(_quantity_id)) > _item.stack_size:
		printerr("Trying to add more than allowable stack size")
		return
	_item_stack = ItemStack.new()
	_item_stack.item = _item
	_item_stack.quantity = int(_quantity_picker.get_item_text(_quantity_id))
	_inventory.insert(_item_stack)
