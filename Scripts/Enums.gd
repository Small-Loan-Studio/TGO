class_name Enums
extends RefCounted

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

# Unused Currently
enum ItemType {
	# Key or Quest items, essentials to story progression. Do not allow discarding of these
	KEY,
	# Things we can use or consume
	CONSUMABLE,
	# This might be stubbed out further in the future Items.Helmet, Items.Gloves, if we have those
	EQUIPPABLE,
}

const AUDIO_BUS_INFO = {
	AudioBus.MASTER: [0, "Global"],
	AudioBus.BACKGROUND_MUSIC: [1, "Background Music"],
	AudioBus.SOUND_EFFECTS: [2, "Sound Effects"],
	AudioBus.AMBIENT: [3, "Environmental Sounds"],
	AudioBus.MENU_EFFECTS: [4, "Menu"],
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
