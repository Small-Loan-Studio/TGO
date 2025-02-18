class_name SimpleTorch
extends GearSpec

var parent_item: Item

func on_equip(c: Character) -> void:
  print("%s equips %s" % [c.id, parent_item.id])

func on_remove(c: Character) -> void:
  print("%s unequips %s" % [c.id, parent_item.id])

func on_use(c: Character) -> void:
  print("%s used %s" % [c.id, parent_item.id])
