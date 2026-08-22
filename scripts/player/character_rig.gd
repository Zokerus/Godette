class_name CharacterRig
extends Node3D

var shieldBlend := 0.0
var blockLegsBlend := 0.0
var is_attacking: bool = false
var currentAttackAnimation: String = ""

@export var right_hand_slot: BoneAttachment3D #TODO might be 
@export var left_hand_slot: BoneAttachment3D
@export var main_hand_item_slot: EquipmentSlot
@export var off_hand_item_slot: EquipmentSlot

@export var weapons: Array[PackedScene] 

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/MovementStateMachine/playback"]
@onready var attackStateMachine: AnimationNodeStateMachinePlayback = animation_tree["parameters/AttackStateMachine/playback"]
@onready var magicStateMachine: AnimationNodeStateMachinePlayback = animation_tree["parameters/MagicStateMachine/playback"]





func travel(animation_name: String)-> void:
	if playback.get_current_node() != animation_name:
		playback.travel(animation_name)


func playAttack(attackName: String) -> void:
	attackStateMachine.travel(attackName)
	animation_tree.set("parameters/UpperBodyActionOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/ActionTransition/transition_request", "Melee")


func defend(delta: float, is_defending: bool, speedRatio: float)-> void:
	var upperTarget: float = float(is_defending)
	var lowerTarget: float = 0.0
	if is_defending:
		lowerTarget = 1.0 - speedRatio 
	
	shieldBlend = move_toward(shieldBlend, upperTarget, delta * 4.0)
	blockLegsBlend= move_toward(blockLegsBlend, lowerTarget, delta * 4.0)
	animation_tree.set("parameters/ShieldBlendUpperBody/blend_amount", shieldBlend)
	animation_tree.set("parameters/ShieldBlendLowerBody/blend_amount", blockLegsBlend)


func switchWeapons(weapon: bool)-> BaseWeapon:
	main_hand_item_slot.remove_child(main_hand_item_slot.get_child(0))
	main_hand_item_slot.add_child(weapons[int(!weapon)].instantiate())
	
	return main_hand_item_slot.get_child(0)

func castSpell(spellName: String) -> void:
	magicStateMachine.travel(spellName)
	animation_tree.set("parameters/ActionTransition/transition_request", "Magic")
	animation_tree.set("parameters/UpperBodyActionOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


## Plays a character reaction animation through the shared reaction OneShot.
func playReaction(reaction: StringName) -> void:
	animation_tree.set("parameters/UpperBodyActionOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/FullBodyActionOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

	animation_tree.set("parameters/HitTransition/transition_request", str(reaction))
	animation_tree.set("parameters/ReactionOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
