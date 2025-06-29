class_name NPCConfig
extends Resource

@export var character_id: String
@export var sprite_sheet: SpriteFrames
@export var valid_timelines: Array[String]

@export var examine_text: String = ""
@export var examine_effects: Array[Effect] = []

@export var show_item_effects: Array[Effect] = []
@export var give_item_effects: Array[Effect] = []
