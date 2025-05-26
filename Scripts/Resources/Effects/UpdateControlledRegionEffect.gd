class_name UpdateControlledRegionEffect
extends Effect

@export var region_id: String = ""
@export_enum("passable", "visible", "toggle", "unchanged") var passable_state: String = "unchanged"
@export_enum("passable", "visible", "toggle", "unchanged") var visible_state: String = "unchanged"

func act(actor_id: String, cur_level: LevelBase) -> Variant:
	var region: ControlledRegion = cur_level.get_region_by_id(region_id)
	if region == null:
		printerr("Failed to find controlled region with id: %s" % [region_id])
		return null

	var old_state := Driver.instance().region_state_mgr.get_state(region_id)
	
	if passable_state != "unchanged":
		match passable_state:
			"passable":
				region.passable = true
			"unpassable":
				region.passable = false
			"toggle":
				region.passable = !region.passable

	if visible_state != "unchanged":
		match visible_state:
			"visible":
				region.visible = true
			"invisible":
				region.visible = false
			"toggle":
				region.visible = !region.visible

	return null