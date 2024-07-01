class_name Utils
extends RefCounted

# converts an angle relative to Vector2.UP into a direction;
# the angle is expected to be radians between [-TAU, TAU]
static func angle_to_direction(angle_rad: float) -> Enums.Direction:
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
