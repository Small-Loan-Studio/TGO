## The possible states of a region
class_name RegionState
extends Resource

## Whether entities can pass through this region
@export var passable: bool = true

## Whether this region is visible
@export var visible: bool = true

## Custom properties that don't fit the standard model
@export var extra: Dictionary = {}

func clone() -> RegionState:
	var rs: RegionState = RegionState.new()
	rs.passable = passable
	rs.visible = visible
	rs.extra = extra.duplicate(true)
	return rs

func equals(o: RegionState) -> bool:
	return passable == o.passable && visible == o.visible && extra == o.extra