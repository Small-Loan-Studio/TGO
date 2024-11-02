class_name Enums
extends RefCounted

enum CheckOp {
	EXISTS,
	LT,
	LTE,
	EQ,
	GTE,
	GT,
}

enum TriggerFailure { ID_MASK, CONDITIONS }

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTH_EAST,
	NORTH_WEST,
	SOUTH_EAST,
	SOUTH_WEST,
}

enum DirectionMode { FOUR, EIGHT }

enum MoveMode {
	WALK,
	SPRINT,
	PUSH_PULL,
}

enum InputAction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	INTERACT,
}

enum LightLevel {
	OFF,
	NORMAL,
	BRIGHT,
	SPECIAL,
}

enum MenuType { NONE, DEBUG }

enum AudioTrack {
	NONE,
	SKETCH_1,
	SKETCH_2,
}

enum AudioBus {
	MASTER,
	BACKGROUND_MUSIC,
	SOUND_EFFECTS,
	AMBIENT,
	MENU_EFFECTS,
}

enum ItemType {
	# Key or Quest items, essentials to story progression. Do not allow discarding of these
	KEY,
	# Things we can use or consume
	CONSUMABLE,
	# This might be stubbed out further in the future Items.Helmet, Items.Gloves, if we have those
	EQUIPPABLE,
}

enum TargetType {
	NONE,
	INTERACTABLE,
	MOVEABLE_BLOCK,
}

enum ActionVerb { DEFAULT, PICK_UP, TALK, PUSH_PULL, RELEASE, USE }

enum QuestState { DORMANT, ACTIVE, FAILED, COMPLETED }
enum QuestConditionType { VARIABLE, INVENTORY }

const AUDIO_BUS_INFO = {
	AudioBus.MASTER: [0, "Global"],
	AudioBus.BACKGROUND_MUSIC: [1, "Background Music"],
	AudioBus.SOUND_EFFECTS: [2, "Sound Effects"],
	AudioBus.AMBIENT: [3, "Environmental Sounds"],
	AudioBus.MENU_EFFECTS: [4, "Menu"],
}

const DIRECTION_PUSH_PULL_AXIS := {
	Direction.NORTH: Vector2(0, 1),
	Direction.SOUTH: Vector2(0, 1),
	Direction.EAST: Vector2(1, 0),
	Direction.WEST: Vector2(1, 0),
}

const QUEST_STATE_NAME = {
	"dormant": QuestState.DORMANT,
	"active": QuestState.ACTIVE,
	"failed": QuestState.FAILED,
	"completed": QuestState.COMPLETED,
}

# gdlint:ignore=class-variable-name
static var DIRECTION_VECTOR := {
	Direction.NORTH: Vector2(0, -1),
	Direction.SOUTH: Vector2(0, 1),
	Direction.EAST: Vector2(1, 0),
	Direction.WEST: Vector2(-1, 0),
	Direction.NORTH_EAST: Vector2(1, -1).normalized(),
	Direction.SOUTH_EAST: Vector2(1, 1).normalized(),
	Direction.NORTH_WEST: Vector2(-11, -1).normalized(),
	Direction.SOUTH_WEST: Vector2(-1, 1).normalized(),
}


static func direction_name(da: Direction) -> String:
	match da:
		Direction.NORTH:
			return "north"
		Direction.SOUTH:
			return "south"
		Direction.EAST:
			return "east"
		Direction.WEST:
			return "west"
		Direction.NORTH_EAST:
			return "northeast"
		Direction.NORTH_WEST:
			return "northwest"
		Direction.SOUTH_EAST:
			return "southeast"
		Direction.SOUTH_WEST:
			return "southwest"
	assert(false, "Unexpected Direction value: " + str(da))
	return "north"


static func direction_vector(da: Direction) -> Vector2:
	return DIRECTION_VECTOR[da]


static func direction_push_pull_axis(d: Direction) -> Vector2:
	return DIRECTION_PUSH_PULL_AXIS[d]


static func move_mode_name(mm: MoveMode) -> String:
	match mm:
		MoveMode.WALK:
			return "walk"
		MoveMode.SPRINT:
			return "sprint"
		MoveMode.PUSH_PULL:
			return "push/pull"
	return "unknown"


static func input_action_name(ia: InputAction) -> String:
	match ia:
		InputAction.UP:
			return "up"
		InputAction.DOWN:
			return "down"
		InputAction.LEFT:
			return "left"
		InputAction.RIGHT:
			return "right"
		InputAction.INTERACT:
			return "interact"
	assert(false, "Invalid Input action: " + str(ia))
	return ""


static func light_level_name(ll: LightLevel) -> String:
	match ll:
		LightLevel.OFF:
			return "off"
		LightLevel.NORMAL:
			return "normal"
		LightLevel.BRIGHT:
			return "bright"
		LightLevel.SPECIAL:
			return "special"
	assert(false, "Invalid light level: " + str(ll))
	return ""


static func audio_track_path(track: AudioTrack) -> String:
	match track:
		AudioTrack.NONE:
			return ""
		AudioTrack.SKETCH_1:
			return "res://Audio/TSO Sketch 1.mp3"
		AudioTrack.SKETCH_2:
			return "res://Audio/TSO Sketch 2.mp3"
		_:
			printerr("Passed an unknown audio track id: ", track)
			return ""


static func audio_bus_index(bus: AudioBus) -> int:
	return AUDIO_BUS_INFO[bus][0]


static func audio_bus_description(bus: AudioBus) -> String:
	return AUDIO_BUS_INFO[bus][1]


static func action_verb_name(av: ActionVerb) -> String:
	match av:
		ActionVerb.PICK_UP:
			return "Pick Up"
		ActionVerb.TALK:
			return "Talk"
		ActionVerb.USE:
			return "Use"
		ActionVerb.PUSH_PULL:
			return "Grab"
		ActionVerb.RELEASE:
			return "Release"
		ActionVerb.DEFAULT:
			return "Interact"
	printerr("Unknown action verb name requested: ", av)
	return "Interact"


static func check_op_eval_int(op: CheckOp, x: int, y: int) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res


static func check_op_eval_float(op: CheckOp, x: float, y: float) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res


static func check_op_eval_bool(op: CheckOp, x: bool, y: bool) -> bool:
	if op == CheckOp.EQ:
		return x == y
	printerr("%s not supported as a boolean comparison" % [op])
	return false


static func check_op_eval_str(op: CheckOp, x: String, y: String) -> bool:
	var res := false
	match op:
		CheckOp.LTE:
			res = x <= y
		CheckOp.LT:
			res = x < y
		CheckOp.EQ:
			res = x == y
		CheckOp.GT:
			res = x > y
		CheckOp.GTE:
			res = x >= y
		CheckOp.EXISTS:
			printerr("EXISTS not defined without context")
	return res

static func quest_state_name(st: QuestState) -> String:
	match st:
		QuestState.DORMANT:
			return "dormant"
		QuestState.ACTIVE:
			return "active"
		QuestState.FAILED:
			return "failed"
		QuestState.COMPLETED:
			return "completed"
	printerr("Unknown quest state converted to string: ", st)
	return "unknown"

static func quest_state_from_str(str: String) -> QuestState:
	str = str.to_lower()
	if QUEST_STATE_NAME.has(str):
		return QUEST_STATE_NAME[str]
	printerr("Unable to resolve quest state %s, returning default" % [str])
	return QuestState.DORMANT