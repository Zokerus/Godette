class_name CombatComponent
extends Node

enum CombatMode {
	MELEE,
	RANGED,
	MAGIC
}

@export var character: CharacterContext
@export_category("Components")
@export var meleeComponent: MeleeComponent
@export var rangeComponent: Node
@export var magicComponent: MagicComponent

var activeCombatMode: CombatMode = CombatMode.MELEE
var isPerformingAction := false
var isDefending := false

func canStartAction() -> bool:
	return !isPerformingAction and !isDefending

func startAction() -> void:
	isPerformingAction = true

func finishAction() -> void:
	isPerformingAction = false

func startDefend() -> void:
	if !isPerformingAction:
		isDefending = true

func stopDefend() -> void:
	isDefending = false

func setCombatMode(mode: CombatMode) -> void:
	if !isPerformingAction:
		activeCombatMode = mode

func attack() -> void:
	match activeCombatMode:
		CombatMode.MELEE:
			if meleeComponent != null:
				meleeComponent.attack()
		#CombatMode.RANGED:
			#if rangeComponent != null:
				#rangeComponent.attack()
		CombatMode.MAGIC:
			if magicComponent != null:
				magicComponent.cast_spell()
	

func getHit(hitType: StringName) -> void:
	cancelCurrentAction()
	character.rig.playReaction(hitType)

func cancelCurrentAction() -> void:
	isPerformingAction = false
	isDefending = false
	
	if meleeComponent != null:
		meleeComponent.cancelAttack()
	
	#if magicComponent != null:
		#magicComponent.cancelCast()
	#
	#if rangeComponent != null:
		#rangeComponent.cancelAttack()
