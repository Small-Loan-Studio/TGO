class_name CharacterStat
extends Resource

@export var typ: Enums.Stat
@export var value: float
@export var max_value: float
@export var default_max: float = 100

func reset() -> void:
  value = default_max
  max_value = default_max


func drain(n: float) -> void:
  value = clampf(value - n, 0, max_value)


func reduce(n: float) -> void:
  max_value = clampf(max_value - n, 0, max_value)
  value = clampf(value, 0, max_value)