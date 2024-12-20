class_name DebugInventory
extends HBoxContainer

const ITEM_PATH = "res://Scripts/Resources/Items"

var _mgr: InventoryManager
var _tgt_id: String
# Dictionary[String, Item]
var _item_dict: Dictionary = {}

@onready var _item_picker: OptionButton = $ItemPicker
@onready var _quantity_picker: SpinBox = $QuantityRange


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


func setup(mgr: InventoryManager, inv_id: String) -> void:
	_mgr = mgr
	_tgt_id = inv_id
	update_inv_options()


func remove_item() -> void:
	var inventory := _mgr.get_inventory(_tgt_id)
	var item_id: int = _item_picker.get_selected_id()
	if item_id == -1:
		printerr("No item or quantity selected")
		return
	inventory.remove_by_id(_item_picker.get_item_text(item_id), _quantity_picker.value)
	_quantity_picker.hide()
	_quantity_picker.show()


func add_item() -> void:
	var item_id: int = _item_picker.get_selected_id()
	if item_id == -1:
		printerr("No item or quantity selected")
		return
	var item := _item_dict[_item_picker.get_item_text(item_id)] as Item
	if _quantity_picker.value > item.stack_size:
		printerr("Trying to add more than allowable stack size")
		return
	if _quantity_picker.value == 0:
		printerr("Trying to add zero items to inventory")
		return

	var item_stack := ItemStack.new()
	item_stack.item = item
	item_stack.quantity = _quantity_picker.value
	_mgr.get_inventory(_tgt_id).insert(item_stack)
	_quantity_picker.hide()
	_quantity_picker.show()
