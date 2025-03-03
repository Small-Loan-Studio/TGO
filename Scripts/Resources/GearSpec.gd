class_name GearSpec
extends Resource


func on_equip(_c: Character) -> void:
  pass


func on_remove(_c: Character) -> void:
  pass


func on_use(_c: Character) -> void:
  pass


func save_state(_c: Character) -> Dictionary:
  return {}


func load_state(_c: Character, _data: Variant) -> void:
  pass