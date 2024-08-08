extends LevelBase

@onready var npc: Character = $TestNPC


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var facing_vec: Vector2 = driver.player.position - npc.position
	var devin_facing := npc.position.angle_to(facing_vec)
	var direction := Utils.angle_to_direction(devin_facing)
	print(devin_facing)
	print(direction)
