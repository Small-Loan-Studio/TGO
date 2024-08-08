class_name InteractableLevelLoad
extends InteractableAction

# @export var load_level: PackedScene
@export var load_level_path: String


func act(_actor: Character, cur_level: LevelBase) -> void:
	if cur_level == null:
		return
	
	var load_level := load(load_level_path) as PackedScene
	cur_level.swap_to_level(load_level.instantiate() as LevelBase)