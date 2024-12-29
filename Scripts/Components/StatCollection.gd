class_name StatCollection
extends Node

@export var stats: Array[CharacterStat] = []

# Map[Enums.Stat, CharacterStat]
var _stats: Dictionary = {}

func _ready() -> void:
  for st in stats:
    _stats[st.typ] = st



func get_stat(stat: Enums.Stat) -> CharacterStat:
  return _stats[stat]