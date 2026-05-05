class_name CharacterRig
extends Node3D

var shieldBlend := 0.0
var blockLegsBlend := 0.0
var is_attacking: bool = false
var currentAttackAnimation: String = ""

@export var right_hand_slot: BoneAttachment3D
@export var left_hand_slot: BoneAttachment3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]
@onready var attackStateMachine: AnimationNodeStateMachinePlayback = animation_tree["parameters/AttackStateMachine/playback"]



func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)


func playAttack(attackName: String) -> void:
	attackStateMachine.travel(attackName)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func defend(delta: float, is_defending: bool, speedRatio: float)-> void:
	shieldBlend = move_toward(shieldBlend, float(is_defending), delta * 4.0)
	blockLegsBlend= move_toward(blockLegsBlend, 1.0 - speedRatio, delta * 4.0)
	animation_tree.set("parameters/ShieldBlendUpperBody/blend_amount", shieldBlend)
	animation_tree.set("parameters/ShieldBlendLowerBody/blend_amount", blockLegsBlend)


func switchWeapons(weapon: bool)-> void:
	right_hand_slot.get_child(0).visible = weapon
	right_hand_slot.get_child(1).visible = !weapon

func castSpell(spellName: String) -> void:
	animation_tree.set("parameters/MagicTransition/transition_request", spellName)
	animation_tree.set("parameters/MagicOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
