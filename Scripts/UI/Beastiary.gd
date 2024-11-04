extends HBoxContainer

class_name Beastiary

@export var monster_codex: Array[BeastiaryEntry]
@onready var codex_holder: Control = $main/ScrollContainer/codex_holder
@onready var card: PackedScene = preload("res://Scenes/UI/Journal/Card.tscn")


func _ready() -> void:
	for monster: BeastiaryEntry in monster_codex:
		var instance: Control = card.instantiate()
		if monster.seen == true:
			print(monster.beast_name)
			codex_holder.add_child(instance)
			instance.set_details(
				monster.beast_name, monster.beast_description, monster.beast_picture
			)
		else:
			codex_holder.add_child(instance)
