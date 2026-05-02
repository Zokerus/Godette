extends Node3D
class_name CharacterRig

signal jumpTakeoffRequested

var shieldBlend := 0.0
var blockLegsBlend := 0.0
var is_attacking: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]

func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)

func requestJumpTakeoff() -> void:
	jumpTakeoffRequested.emit()

func attack()-> void:
	if !is_attacking:
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _updateAttackState(value: bool)-> void:
	is_attacking = value

func defend(delta: float, is_defending: bool, speedRatio: float)-> void:
	shieldBlend = move_toward(shieldBlend, float(is_defending), delta * 4.0)
	blockLegsBlend= move_toward(blockLegsBlend, 1.0 - speedRatio, delta * 4.0)
	animation_tree.set("parameters/ShieldBlendUpperBody/blend_amount", shieldBlend)
	animation_tree.set("parameters/ShieldBlendLowerBody/blend_amount", blockLegsBlend)
