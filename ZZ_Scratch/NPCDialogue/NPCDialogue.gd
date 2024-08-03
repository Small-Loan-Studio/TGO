extends Node2D


@onready var npc: Character = $TestNPC
@onready var devin: Devin = $Devin

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var facing_vec := devin.position - npc.position
	var devin_facing := npc.position.angle_to(facing_vec)
	var direction := Utils.angle_to_direction(devin_facing)
	print(devin_facing)
	print(direction)
