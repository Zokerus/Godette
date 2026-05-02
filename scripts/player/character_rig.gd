extends Node3D
class_name CharacterRig

signal jumpTakeoffRequested

var shieldBlend := 0.0
var blockLegsBlend := 0.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]

func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)

func requestJumpTakeoff() -> void:
	jumpTakeoffRequested.emit()

func attack()-> void:
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func defend(delta: float, forward: bool, speedRatio: float)-> void:
	shieldBlend = move_toward(shieldBlend, float(forward), delta * 4.0)
	animation_tree.set("parameters/ShieldBlendUpperBody/blend_amount", shieldBlend)
	animation_tree.set("parameters/ShieldBlendLowerBody/blend_amount", 1.0 - speedRatio)
