class_name StatCollection
extends Node

@export var stats: Array[CharacterStat] = []

# Map[Enums.Stat, CharacterStat]
var _stats: Dictionary = {}


func _ready() -> void:
	build_dict()


func build_dict() -> void:
	_stats.clear()
	for st in stats:
		_stats[st.typ] = st


func get_stat(stat: Enums.Stat) -> CharacterStat:
	return _stats[stat]


func save() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for st in stats:
		arr.append(st.save())
	return arr


func load(data: Array[Dictionary]) -> void:
	stats.clear()
	for dict in data:
		stats.append(CharacterStat.from_save(dict))
	build_dict()
