@tool
class_name DoorRegion
extends ControlledRegion

@onready var _sprite: Sprite2D = $Display
@onready var _interactable: Interactable = $Interactable

## The sprite to use when the door is closed
@export var closed_sprite: Texture2D

## The sprite to use when the door is open
@export var open_sprite: Texture2D

## Conditions that must be met for a door to be unlocked. If empty the door
## defaults to unlocked. A "locked" door may not change state -- e.g. it will
## not open if closed and will not close if open.
@export var unlocked: Array[TriggerCondition] = []

## When you "use" the door successfully what happens? Toggle will alternate
## between open and closed. Open will only open, Close will only close.
## If the door is not unlocked no action will occur.
@export_enum("open", "close", "toggle") var use_action: String = "toggle"

var is_open: bool:
	get:
		return _rsm.get_state(region_id).passable
	set(v):
		printerr("%s.open may not be set directly" % [region_id])


func _enter_tree() -> void:
	super._enter_tree()
	add_to_group(Utils.GroupNames.Doors)


func _exit_tree() -> void:
	super._exit_tree()
	remove_from_group(Utils.GroupNames.Doors)


func _ready() -> void:
	super._ready()

	var toggle_effect: ToggleDoorEffect = ToggleDoorEffect.new()
	toggle_effect.door_id = region_id
	toggle_effect.door_action = use_action
	_interactable.action_map[Enums.ActionVerb.USE] = [toggle_effect]


func _apply_state(state: RegionState) -> void:
	var door_open := state.passable
	visible = state.visible
	_collider.disabled = door_open
	
	if door_open:
		_sprite.texture = open_sprite
	else:
		_sprite.texture = closed_sprite

func open() -> void:
	_rsm.unblock_region(region_id)

func close() -> void:
	_rsm.block_region(region_id)

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func _get_configuration_warnings() -> PackedStringArray:
	return super._get_configuration_warnings()