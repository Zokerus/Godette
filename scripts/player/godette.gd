extends Node3D
class_name PlayerRig

signal jumpTakeoffRequested

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)

func requestJumpTakeoff() -> void:
	jumpTakeoffRequested.emit()
