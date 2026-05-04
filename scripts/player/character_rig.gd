extends Node3D
class_name CharacterRig

signal jumpTakeoffRequested

var shieldBlend := 0.0
var blockLegsBlend := 0.0
var is_attacking: bool = false
var currentAttackAnimation: String = ""

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]
@onready var attackStateMachine: AnimationNodeStateMachinePlayback = animation_tree["parameters/AttackStateMachine/playback"]
@onready var attack_timer: Timer = $AttackTimer

func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)

func requestJumpTakeoff() -> void:
	jumpTakeoffRequested.emit()


func playAttack(attackName: String) -> void:
	attackStateMachine.travel(attackName)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func attack()-> void:
	if !is_attacking:
		if attack_timer.time_left:
			attackStateMachine.travel("Slice")
		else:
			attackStateMachine.travel("Chop")
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_attacking = true

func _on_Attack_Animation_Update(value: bool)-> void:
	is_attacking = value
	if !is_attacking:
		attack_timer.start()

func defend(delta: float, is_defending: bool, speedRatio: float)-> void:
	shieldBlend = move_toward(shieldBlend, float(is_defending), delta * 4.0)
	blockLegsBlend= move_toward(blockLegsBlend, 1.0 - speedRatio, delta * 4.0)
	animation_tree.set("parameters/ShieldBlendUpperBody/blend_amount", shieldBlend)
	animation_tree.set("parameters/ShieldBlendLowerBody/blend_amount", blockLegsBlend)

func switchWeapons(weapon: bool)-> void:
	pass
