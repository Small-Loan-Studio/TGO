class_name Enums

extends RefCounted

enum Direction {
  North,
  South,
  East,
  West,
  NorthEast,
  NorthWest,
  SouthEast,
  SouthWest,
}

static func direction_name(da: Direction) -> String:
  match da:
    Direction.North:
      return "north"
    Direction.South:
      return "south"
    Direction.East:
      return "east"
    Direction.West:
      return "west"
    Direction.NorthEast:
      return "northeast"
    Direction.NorthWest:
      return "northwest"
    Direction.SouthEast:
      return "southeast"
    Direction.SouthWest:
      return "southwest"
  printerr("Unexpected Direction value: " + str(da))
  return "north"

enum InputAction {
  Up,
  Down,
  Left,
  Right
}

static func input_action_name(ia: InputAction) -> String:
  match ia:
    InputAction.Up:
      return "up"
    InputAction.Down:
      return "down"
    InputAction.Left:
      return "left"
    InputAction.Right:
      return "right"
  assert(false, "Invalid Input action")
  return ""