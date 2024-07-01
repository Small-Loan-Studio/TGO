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
  printerr("Unexpected Direction value: " + str(da))
  return "north"

enum InputAction {
  UP,
  DOWN,
  LEFT,
  RIGHT
}

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
  assert(false, "Invalid Input action")
  return ""