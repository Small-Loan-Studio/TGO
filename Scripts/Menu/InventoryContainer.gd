class_name InventoryContainer
extends GridContainer

var _max_height: int = 1
var _mgr: InventoryManager

var _ctrl: ControllerBase
var _item_res: Array[Item] = []
var _hold_scenes: Array[ItemDisplayRect] = []

# which index is currently selected
var _selected_idx := 0

# how many rows have scrolled off the top
var _y_offset := 0

# cursor position within the grid; constrained to the grid size and doesn't
# take into account the full array size or need for offset/scrolling
var _cursor_pos: Vector2i = Vector2i.ZERO

const Scene: PackedScene = preload("res://Scenes/Menu/InventoryContainer.tscn")


static func mk(x: int, y: int, ctrl: ControllerBase, items: Array[Item]) -> InventoryContainer:
	var scn := InventoryContainer.Scene.instantiate() as InventoryContainer
	scn.setup(x, y, ctrl, items)
	return scn


var has_setup: bool = false
func setup(x: int, y: int, ctrl: ControllerBase, items_for_display: Array[Item]) -> void:
	self._mgr = Driver.instance().inventory_mgr
	self.columns = x
	self._ctrl = ctrl
	self._item_res = items_for_display
	print("Items (%d): %s" % [len(items_for_display), items_for_display])
	has_setup = true

	print("InventoryContainer.setup(%d, %d, ...)" % [x, y])

	if y > 0:
		_max_height = y

	for idx in range(x * y):
		var scn := ItemDisplayRect.mk(idx)
		if idx < len(items_for_display) - 1:
			scn.set_item(items_for_display[idx])
		_hold_scenes.append(scn)
		add_child(scn)


func _exit_tree() -> void:
	for scn in _hold_scenes:
		scn.queue_free()
	_hold_scenes.clear()


# convert cursor position to the item index within the array; this accounts
# for offset/any scrolling thas has been done
func _from_xy(xy: Vector2i) -> int:
	return (_y_offset * columns) + xy.y + xy.x


func _to_xy_raw(idx: int) -> Vector2i:
	var y := (idx / columns) as int
	var x := idx - (y * columns)
	return Vector2(x, y)
	
func _process(_delta: float) -> void:
	if !has_setup:
		return

	if !_process_input():
		return
	
	_debug_print()
	# print("selected idx: %d: %s : %d" % [_selected_idx, _cursor_pos, _y_offset])


func _process_input() -> bool:
	var max_idx := len(_item_res) - 1
	var idx := _selected_idx
	var single_col := columns == 1

	if _ctrl.just_pressed(Enums.InputAction.UP):
		if idx == 0:
			idx = max_idx
		else:
			idx -= columns
	elif _ctrl.just_pressed(Enums.InputAction.DOWN):
		if idx == max_idx:
			idx = 0
		else:
			idx += columns
	elif !single_col && _ctrl.just_pressed(Enums.InputAction.LEFT):
		if idx == 0:
			idx = max_idx
		else:
			idx -= 1
	elif !single_col && _ctrl.just_pressed(Enums.InputAction.RIGHT):
		if idx == max_idx:
			idx = 0
		else:
			idx += 1
	else:
		return false

	if idx < 0:
		idx = 0
		_y_offset = 0
	if idx > max_idx:
		idx = max_idx
	_selected_idx = idx

	# var old_pos := _cursor_pos
	var new_pos := _to_xy_raw(idx)
	# var aoeu := "%s -> %s" % [_cursor_pos, new_pos]

	_cursor_pos = new_pos
	# print("%d -> %d -> %d :: %s -> %s" % [old_idx, mid_idx, idx, old_pos, _cursor_pos])

	return true

func _debug_print() -> void:
	var cx := _cursor_pos.x
	var cy := _cursor_pos.y

	print("idx: %d, y_offset: %d, cur_pos: %s, cur_pos + offset %s" % [_selected_idx, _y_offset, _cursor_pos, Vector2i(cx, cy + _y_offset)])
	for y in range(_max_height):
		var line: String
		if y == 0:
			line = "     "
			for x in range(columns):
				line += "  %d  " % [x]
			print(line)

		line = "%d    " % [y + _y_offset]
		for x in range(columns):
			if cx == x && cy == y:
				line += " [X] "
			else:
				line += " [ ] "
		print(line)
	
	print("")