class_name UpdateControlledRegionEffect
extends Effect

@export var region_id: String = ""
@export_enum("passable", "visible", "toggle", "unchanged") var passable_state: String = "unchanged"
@export_enum("passable", "visible", "toggle", "unchanged") var visible_state: String = "unchanged"


func act(_actor_id: String, cur_level: LevelBase) -> Variant:
	var region: ControlledRegion = cur_level.get_region_by_id(region_id)
	if region == null:
		printerr("Failed to find controlled region with id: %s" % [region_id])
		return null

	var rsm := Driver.instance().region_state_mgr
	var old_state := rsm.get_state(region_id)

	if passable_state != "unchanged":
		match passable_state:
			"passable":
				old_state.passable = true
			"unpassable":
				old_state.passable = false
			"toggle":
				old_state.passable = !old_state.passable

	if visible_state != "unchanged":
		match visible_state:
			"visible":
				old_state.visible = true
			"invisible":
				old_state.visible = false
			"toggle":
				old_state.visible = !region.visible

	rsm.set_state(region_id, old_state)

	return null
