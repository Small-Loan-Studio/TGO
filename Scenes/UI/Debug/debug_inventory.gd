class_name DebugInventory
extends HBoxContainer

@onready var _inventory: Inventory
@onready var ItemPicker : OptionButton = $ItemPicker
@onready var QuantityPicker: OptionButton = $QuantityPicker
@onready var item_dict: Dictionary = {}

var itemStack : ItemStack = ItemStack.new()
var itemId: int
var quantityId: int = -1
var item: Item

const ITEM_PATH = "res://Scripts/Resources/Items"

func update_inv_options() ->void:
	#Loads configured items into the ItemPicker list
	item_dict.clear()
	ItemPicker.clear()
	
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
				item_dict[key] = config
				if ItemPicker:
					ItemPicker.add_item(key)
		item_file = dir.get_next()

func setup(inv: Inventory) -> void:
	_inventory = inv
	update_inv_options()

func remove_item() -> void:
	itemId = ItemPicker.get_selected_id()
	quantityId = QuantityPicker.get_selected_id() 
	if (itemId == -1 or quantityId == -1):
		printerr("No item or quantity selected")
		return
	_inventory.remove_by_id(ItemPicker.get_item_text(itemId), int(QuantityPicker.get_item_text(quantityId)))

func add_item() -> void:
	itemId = ItemPicker.get_selected_id()
	quantityId = QuantityPicker.get_selected_id()
	if (itemId == -1 or quantityId == -1):
		printerr("No item or quantity selected")
		return
	item = item_dict[ItemPicker.get_item_text(itemId)]
	if int(QuantityPicker.get_item_text(quantityId)) > item.stack_size:
		printerr("Trying to add more than allowable stack size")
		return
	itemStack.item = item
	itemStack.quantity = int(QuantityPicker.get_item_text(quantityId))
	_inventory.insert(itemStack)
