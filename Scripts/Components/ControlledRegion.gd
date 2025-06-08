@tool
class_name ControlledRegion
extends Node2D

## The dotted identifier for this region
@export var region_id: String
@export var _collider: CollisionShape2D

var _rsm: RegionStateManager
var _collider_cache: CollisionShape2D
var _layer_cache: int
var _layer_mask_cache: int

# ## The default state of this region
# @export var initial_state: RegionState

var _physics_body: StaticBody2D:
	get:
		if has_node("StaticBody2D"):
			return $StaticBody2D
		return null
	set(v):
		printerr("ControlledRegion._physics_body is read only")


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return

	# Ensure we have a unique identifier
	if region_id.is_empty():
		printerr("ControlledRegion is no id set, will not function")
		return

	add_to_group(Utils.GroupNames.ControlledRegions)
	_rsm = Driver.instance().region_state_mgr
	_rsm.region_changed.connect(_on_state_change)


func _ready() -> void:
	if Engine.is_editor_hint() || region_id.is_empty():
		print("ControlledRegion._ready but region_id is empty: %s" % [name])
		return

	# State initialization removed for the time being bc it's complex to
	# sort out when to initialize vs when the state was explicitly set, e.g.,
	# by game load.
	#
	# # Initialize state if it doesn't exist
	# if not _rsm.has(region_id)
	# 	_rsm.set_state(region_id, initial_state)

	_physics_body.collision_layer = _layer_cache
	_physics_body.collision_mask = _layer_mask_cache
	if _collider != null:
		# Have to do this because reparenting doesn't seem to get saved through
		# level unload. Uncertain why.
		_collider_cache = _collider.duplicate()
		_physics_body.add_child(_collider_cache)
		_collider_cache.set_owner(_physics_body)

	# Initial state sync
	_sync_state()


func _exit_tree() -> void:
	if Engine.is_editor_hint() || region_id.is_empty():
		return

	remove_from_group(Utils.GroupNames.ControlledRegions)
	_rsm.region_changed.disconnect(_on_state_change)


func _on_state_change(key: String, _old: RegionState, _new: RegionState) -> void:
	# Check if the change is relevant to this region
	if key != region_id:
		return
	_sync_state()


func _sync_state() -> void:
	var new_state: RegionState = _rsm.get_state(region_id)
	if new_state == null:
		printerr("ControlledRegion._sync_state: no state found for region_id %s" % [region_id])
		return
	_collider.disabled = new_state.passable
	if _collider_cache != null:
		_collider_cache.disabled = new_state.passable
	_apply_state(new_state)


func _apply_state(_state: RegionState) -> void:
	# This method should be overridden by derived classes to handle
	# their specific state changes
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var errs: Array[String] = []
	if _collider == null:
		errs.push_back("ControlledRegion: missing collider")
	if region_id.is_empty():
		errs.push_back("ControlledRegion: missing region_id")
	return errs


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	(
		props
		. append(
			{
				"name": "collision_layer",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD,
				"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
			}
		)
	)
	(
		props
		. append(
			{
				"name": "collision_mask",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD,
				"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
			}
		)
	)
	return props


func _get(property: StringName) -> Variant:
	if property == "collision_layer":
		return _physics_body.collision_layer
	if property == "collision_mask":
		return _physics_body.collision_mask
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == "collision_layer":
		if _physics_body != null:
			_physics_body.collision_layer = value
		_layer_cache = value
		return true
	if property == "collision_mask":
		if _physics_body != null:
			_physics_body.collision_mask = value
		_layer_mask_cache = value
		return true

	return false
