class_name ScratchScenes
extends Node

const SCENES = {
	"Test Movement & Graybox": "res://ZZ_Scratch/Movement/TestMovement.tscn",
	"Peer Physics & Interactables": "res://ZZ_Scratch/PeerPhysics/PeerPhysics.tscn",
}

static func get_scenes() -> Dictionary:
	return SCENES