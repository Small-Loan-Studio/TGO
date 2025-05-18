class_name ControlledRegion
extends Node2D

var _rsm: RegionStateManager

## The dotted identifier for this region
@export var region_id: String

## The default state of this region
@export var initial_state: RegionState

func _enter_tree() -> void:
	# Ensure we have a unique identifier
	if region_id.is_empty():
		printerr("ControlledRegion is no id set, will not function")
		return
	
	_rsm = Driver.instance().region_state_mgr
	_rsm.region_changed.connect(_on_state_change)

func _ready() -> void:
	# Initial state sync
	_sync_state()

func _exit_tree() -> void:
	if region_id.is_empty():
		return

	_rsm.region_changed.disconnect(_on_state_change)

func _on_state_change(key: String, _old: RegionState, _new: RegionState) -> void:
	# Check if the change is relevant to this region
	if key != region_id:
		return
	_sync_state()

func _sync_state() -> void:
	_apply_state(_rsm.get_state(region_id))

func _apply_state(_state: RegionState) -> void:
	# This method should be overridden by derived classes to handle
	# their specific state changes
	pass