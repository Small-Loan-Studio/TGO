class_name Devin
extends Character

@onready var _lamp: Lamp = $Lamp

func _physics_process(delta: float) -> void:
    super._physics_process(delta)
    if _lamp != null:
        _lamp.face(_facing)
