extends CharacterState

@export var idle_state: State

func enter(_ctx: Variant) -> StateChange:
	if(Dialogic.current_timeline != null):
		return StateChange.mk(idle_state)
	return null
	
func run_tick(_delta: float) -> StateChange:
	if(Dialogic.current_timeline != null):
		return StateChange.mk(idle_state)
	return null
