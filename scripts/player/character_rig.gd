extends Node3D
class_name CharacterRig

signal jumpTakeoffRequested

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]

func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)

func requestJumpTakeoff() -> void:
	jumpTakeoffRequested.emit()

func attack()-> void:
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func defend(forward: bool)-> void:
	pass
