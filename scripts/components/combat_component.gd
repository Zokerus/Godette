class_name CombatComponent
extends Node

enum CombatMode {
	MELEE,
	RANGED,
	MAGIC
}
@export_category("Character Rig")
@export var character: CharacterContext
@export_category("Components")
@export var meleeComponent: MeleeComponent
@export var rangeComponent: Node
@export var magicComponent: MagicComponent
@export var activeCoolDown: bool = false

var activeCombatMode: CombatMode = CombatMode.MELEE
var isPerformingAction := false
var isDefending := false

@onready var cool_down_timer: Timer = $CoolDownTimer

func canStartAction() -> bool:
	return !isPerformingAction and !isDefending

func startAction() -> void:
	isPerformingAction = true

func finishAction() -> void:
	if !activeCoolDown:
		isPerformingAction = false
	else:
		cool_down_timer.start()

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


func _on_cool_down_timer_timeout() -> void:
	isPerformingAction = false
