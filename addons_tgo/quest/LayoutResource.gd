class_name QuestLayout
extends Resource

const RESOURCE_PATH := "res://addons_tgo/quest/layout.tres"

@export var zoom: float
@export var scroll_offset: Vector2
@export var positions: Dictionary = {}


static func save(zoom: float, offset: Vector2, nodes: Array[QuestNode]) -> void:
	var res := QuestLayout.new()
	for n in nodes:
		res.positions[n.id] = n.position_offset
	res.zoom = zoom
	res.scroll_offset = offset
	ResourceSaver.save(res, RESOURCE_PATH)


static func load() -> QuestLayout:
	if !FileAccess.file_exists(RESOURCE_PATH):
		return null

	var res := ResourceLoader.load(RESOURCE_PATH) as QuestLayout
	return res
