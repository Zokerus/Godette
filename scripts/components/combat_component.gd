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
var isCoolDown := false

@onready var cool_down_timer: Timer = $CoolDownTimer

func canStartAction() -> bool:
	return !isPerformingAction and !isDefending and !isCoolDown

func startAction() -> void:
	isPerformingAction = true

func finishAction() -> void:
	if activeCoolDown:
		cool_down_timer.start()
		isCoolDown = true
	isPerformingAction = false

func startDefend() -> void:
	if !isPerformingAction:
		isDefending = true

func stopDefend() -> void:
	isDefending = false

func setCombatMode(mode: CombatMode) -> void:
	if !isPerformingAction:
		activeCombatMode = mode

func attack(attack: StringName) -> void:
	match activeCombatMode:
		CombatMode.MELEE:
			if meleeComponent != null:
				meleeComponent.attack(attack)
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
	isCoolDown = false
