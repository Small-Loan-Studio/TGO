class_name InventoryContainer
extends GridContainer

var _max_height: int = 1
var _mgr: InventoryManager

var _ctrl: ControllerBase
var _item_res: Array[Item] = []
var _hold_scenes: Array[ItemDisplayRect] = []
var _acceptable_directions: Array[Enums.InputAction] = []

# which index is currently selected
var _selected_idx := 0

# how many rows have scrolled off the top
var _y_offset := 0
# when the y_offset changes we need to redraw the containers because the "top"
# viewed row will be different
var _last_drawn_y_offset := -1

# cursor position within the grid; constrained to the grid size and doesn't
# take into account the full array size or need for offset/scrolling
var _cursor_pos: Vector2i = Vector2i.ZERO

const Scene: PackedScene = preload("res://Scenes/Menu/InventoryContainer.tscn")


static func mk(x: int, y: int, ctrl: ControllerBase, items: Array[Item]) -> InventoryContainer:
	var scn := InventoryContainer.Scene.instantiate() as InventoryContainer
	scn.setup(x, y, ctrl, items, [
			Enums.InputAction.LEFT,
			Enums.InputAction.RIGHT,
			Enums.InputAction.UP,
			Enums.InputAction.DOWN,
	])
	return scn


func _get_scene(x: int, y: int) -> ItemDisplayRect:
	return _hold_scenes[columns * y + x]

func _set_scene(x: int, y: int, scn: ItemDisplayRect) -> void:
	_hold_scenes[columns * y + x] = scn


var has_setup: bool = false
func setup(
	x: int, y: int,
	ctrl: ControllerBase,
	items_for_display: Array[Item],
	monitored: Array[Enums.InputAction],
) -> void:
	print("InventoryContainer.setup(%d, %d, ...)" % [x, y])
	self._mgr = Driver.instance().inventory_mgr
	self.columns = x
	self._ctrl = ctrl
	self._item_res = items_for_display
	self._acceptable_directions = monitored

	if y > 0:
		_max_height = y

	# order we traverse here is load bearing bc it needs to correspond to the
	# order in which things get added to a grid container
	for idx_y in range(_max_height):
		for idx_x in range(columns):
			var idx := (idx_y * columns) + idx_x
			var scn := ItemDisplayRect.mk(idx)
			_hold_scenes.append(scn)
			if idx < len(items_for_display):
				scn.set_item(items_for_display[idx])
			add_child(scn)
	
	_selected_idx = 0
	_get_scene(0, 0).focus()
	print("InventoryContainer.has_setup = true")
	has_setup = true


func _enter_tree() -> void:
	print("InventoryContainer._enter_tree - %s" % [has_setup])

func _ready() -> void:
	print("InventoryContainer._ready - %s" % [has_setup])


func _exit_tree() -> void:
	for scn in _hold_scenes:
		scn.queue_free()
	_hold_scenes.clear()


func current_item() -> Item:
	if len(_item_res) == 0:
		return null
	if _selected_idx < 0 || _selected_idx >= len(_item_res):
		printerr("selected_idx %d out of range" % [_selected_idx])
		return null
	return _item_res[_selected_idx]


# convert cursor position to the item index within the array; this accounts
# for offset/any scrolling thas has been done
func _from_xy(xy: Vector2i) -> int:
	return ((xy.y + _y_offset) * columns) + xy.x


func _to_xy_raw(idx: int) -> Vector2i:
	var y := (idx / columns) as int
	var x := idx - (y * columns)
	return Vector2(x, y)

func _adjusted_pos() -> Vector2i:
	return Vector2i(_cursor_pos.x, _cursor_pos.y - _y_offset)


func _process(_delta: float) -> void:
	if !has_setup:
		return

	if !_process_input():
		return
	
	var apos := _adjusted_pos()
	
	var should_reflow := _last_drawn_y_offset != _y_offset
	if should_reflow:
		_last_drawn_y_offset = _y_offset

	for y in range(_max_height):
		for x in range(columns):
			if apos.x == x && apos.y == y:
				_get_scene(x, y).focus()
			else:
				_get_scene(x, y).blur()
			if should_reflow:
				var idx := _from_xy(Vector2i(x, y))
				var scn := _get_scene(x, y)
				if idx < len(_item_res):
					scn.set_item(_item_res[idx])
				else:
					scn.set_item(null)


func _process_input() -> bool:
	print(_ctrl.get_just_pressed())
	var max_idx := len(_item_res) - 1
	var idx := _selected_idx
	var single_col := columns == 1
	var can_up := Enums.InputAction.UP in _acceptable_directions
	var can_down := Enums.InputAction.DOWN in _acceptable_directions
	var can_left := Enums.InputAction.LEFT in _acceptable_directions
	var can_right := Enums.InputAction.RIGHT in _acceptable_directions

	if can_up && _ctrl.just_pressed(Enums.InputAction.UP):
		if idx == 0:
			idx = max_idx
		else:
			idx -= columns
	elif can_down  &&  _ctrl.just_pressed(Enums.InputAction.DOWN):
		if idx == max_idx:
			idx = 0
		else:
			idx += columns
	elif can_left && !single_col && _ctrl.just_pressed(Enums.InputAction.LEFT):
		if idx == 0:
			idx = max_idx
		else:
			idx -= 1
	elif can_right &&  !single_col && _ctrl.just_pressed(Enums.InputAction.RIGHT):
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

	_cursor_pos = _to_xy_raw(idx)
	var adjusted := _adjusted_pos()

	if adjusted.y < 0:
		_y_offset = _cursor_pos.y
	elif adjusted.y > (_max_height - 1):
		_y_offset = _y_offset + adjusted.y - (_max_height - 1)
	return true

func _debug_print() -> void:
	var apos := _adjusted_pos()
	var ax := apos.x
	var ay := apos.y

	for y in range(_max_height):
		var line: String
		if y == 0:
			line = "     "
			for x in range(columns):
				line += "  %d  " % [x]
			print(line)

		line = "%d    " % [y + _y_offset]
		for x in range(columns):
			var cur_idx := _from_xy(Vector2i(x, y))
			if cur_idx >= len(_item_res):
				pass
			else:
				if ax == x && ay == y:
					line += " [%2d] " % [cur_idx]
				else:
					line += "  %2d  " % [cur_idx]
		print(line)
	
	print("")