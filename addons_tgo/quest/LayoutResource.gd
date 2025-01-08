class_name QuestLayout
extends Resource

const RESOURCE_PATH := "res://addons_tgo/quest/layout.tres"

@export var positions: Dictionary = {}

static func save(nodes: Array[QuestNode]) -> void:
    var res := QuestLayout.new()
    for n in nodes:
        res.positions[n.id] = n.position_offset
    ResourceSaver.save(res, RESOURCE_PATH)

static func load() -> Dictionary:
    if !FileAccess.file_exists(RESOURCE_PATH):
        return {}

    var res := ResourceLoader.load(RESOURCE_PATH) as QuestLayout
    if res == null:
        res = null
    return res.positions