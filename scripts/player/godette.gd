extends Node3D
class_name PlayerRig

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func travel(animation_name: String)-> void:
	playback.travel(animation_name)
