class_name SimpleTorch
extends GearSpec


func on_equip(c: Character) -> void:
  print("%s equips SimpleTorch" % [c.id])

func on_remove(c: Character) -> void:
  print("%s unequips SimpleTorch" % [c.id])

func on_use(c: Character) -> void:
  print("%s used SimpleTorch" % [c.id])
