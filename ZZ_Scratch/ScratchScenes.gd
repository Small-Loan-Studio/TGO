class_name ScratchScenes
extends Node

const SCENES = {
	"Mario Demo": "res://ZZ_Scratch/MarioDemo/MarioDemo.tscn",
	"Test Movement & Graybox": "res://ZZ_Scratch/Movement/TestMovement.tscn",
	"Peer Physics & Interactables": "res://ZZ_Scratch/PeerPhysics/PeerPhysics.tscn",
	"Audio Manager Volume Prefs": "res://ZZ_Scratch/AudioLevels/AudioLevels.tscn",
	"Dialogic Validation": "res://ZZ_Scratch/DialogicValidation/Dialogic.tscn",
	"Greyboxing": "res://ZZ_Scratch/GreyboxingTools/BadLevelA.tscn",
	"NPC Dialogue": "res://ZZ_Scratch/NPCDialogue/NPCDialogue.tscn",
	"Day Night Cycle": "res://ZZ_Scratch/DayNightCycle/DayNightCycle.tscn",
}


## Returns a dictionary that is String->String.[br]
## [br]
## The keys are a UI-friendly description of the scene and the values are
## the resource path that should be loaded.[br]
## [br]
## Each scene should be fully self-contained as a debug environment and the
## expectation is that we can just load -> instantiate it and add it to the
## game's scene tree.[br]
## [br]
## For details of how this works see Driver.request_debug_load
static func get_scenes() -> Dictionary:
	return SCENES
