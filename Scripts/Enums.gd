class_name Enums
extends RefCounted

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTH_EAST,
	NORTH_WEST,
	SOUTH_EAST,
	SOUTH_WEST,
}

enum InputAction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	INTERACT,
}

enum LightLevel {
	OFF,
	NORMAL,
	BRIGHT,
	SPECIAL,
}

enum MenuType { NONE, DEBUG }


static func direction_name(da: Direction) -> String:
	match da:
		Direction.NORTH:
			return "north"
		Direction.SOUTH:
			return "south"
		Direction.EAST:
			return "east"
		Direction.WEST:
			return "west"
		Direction.NORTH_EAST:
			return "northeast"
		Direction.NORTH_WEST:
			return "northwest"
		Direction.SOUTH_EAST:
			return "southeast"
		Direction.SOUTH_WEST:
			return "southwest"
	assert(false, "Unexpected Direction value: " + str(da))
	return "north"


static func input_action_name(ia: InputAction) -> String:
	match ia:
		InputAction.UP:
			return "up"
		InputAction.DOWN:
			return "down"
		InputAction.LEFT:
			return "left"
		InputAction.RIGHT:
			return "right"
		InputAction.INTERACT:
			return "interact"
	assert(false, "Invalid Input action: " + str(ia))
	return ""


static func light_level_name(ll: LightLevel) -> String:
	match ll:
		LightLevel.OFF:
			return "off"
		LightLevel.NORMAL:
			return "normal"
		LightLevel.BRIGHT:
			return "bright"
		LightLevel.SPECIAL:
			return "special"
	assert(false, "Invalid light level: " + str(ll))
	return ""
