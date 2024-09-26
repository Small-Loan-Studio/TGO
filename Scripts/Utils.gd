class_name Utils
extends RefCounted

const ID_GROUP := "NodesWithID"


## Finds a LevelBase ancestor of a node if it exists. Returns null if none
## found.
static func get_level_parent(node: Node) -> LevelBase:
	var ref := node
	while not (ref is LevelBase):
		ref = ref.get_parent()
		if ref == null:
			printerr("Switch: did not find a LevelBase parent for %s" % [node.name])
			return null

	return ref


# converts an angle relative to Vector2.UP into a direction;
# the angle is expected to be radians between [-TAU, TAU]
static func angle_to_direction(
	angle_rad: float,
	direction_count: Enums.DirectionMode = Enums.DirectionMode.EIGHT,
) -> Enums.Direction:
	match direction_count:
		Enums.DirectionMode.EIGHT:
			return _angle_to_direction_8(angle_rad)
		Enums.DirectionMode.FOUR:
			return _angle_to_direction_4(angle_rad)
	assert(false, "Bad direction mode: " + str(direction_count))
	return _angle_to_direction_4(angle_rad)


static func _angle_to_direction_8(angle_rad: float) -> Enums.Direction:
	# convert to degrees for my trig-lazy brain
	var normalized: float = angle_rad / TAU * 360
	var abs_normalized: float = abs(normalized)
	var side: int = 1 if normalized >= 0 else 0

	var segments: int = (abs_normalized / 22.5) as int

	if segments < 1:
		return Enums.Direction.NORTH
	if segments < 3:
		return [Enums.Direction.NORTH_WEST, Enums.Direction.NORTH_EAST][side]
	if segments < 5:
		return [Enums.Direction.WEST, Enums.Direction.EAST][side]
	if segments < 7:
		return [Enums.Direction.SOUTH_WEST, Enums.Direction.SOUTH_EAST][side]
	return Enums.Direction.SOUTH


static func _angle_to_direction_4(angle_rad: float) -> Enums.Direction:
	# convert to degrees for my trig-lazy brain
	var normalized: float = angle_rad / TAU * 360
	var abs_normalized: float = abs(normalized)
	var side: int = 1 if normalized >= 0 else 0

	var segments: int = (abs_normalized / 45) as int

	if segments < 1:
		return Enums.Direction.NORTH
	if segments < 3:
		return [Enums.Direction.WEST, Enums.Direction.EAST][side]
	return Enums.Direction.SOUTH
