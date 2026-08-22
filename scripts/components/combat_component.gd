class_name CombatComponent
extends Node

enum CombatMode {
	MELEE,
	RANGED,
	MAGIC
}
enum ActionType {
	NONE,
	ATTACK,
	BLOCK
}

@export var activeCombatMode: CombatMode = CombatMode.MELEE
@export_category("Character Rig")
@export var character: CharacterContext
@export_category("Components")
@export var meleeComponent: MeleeComponent
@export var rangeComponent: Node
@export var magicComponent: MagicComponent
@export var healthComponent: HealthComponent
@export var defenseComponent: DefenseComponent
@export var equipmentComponent: EquipmentComponent
@export_category("Cooldown Settings")
@export var attackCooldown: float = 1.2
@export var blockCooldown: float = 1.5
@export var blockCooldownVariance: float = 0.1
@export var blockDuration: float = 1.6
@export var blockDurationVariance: float = 0.2


var isPerformingAction: bool = false
var isDefending: bool = false
var isManualAction: bool = false
var currentActionType: ActionType = ActionType.NONE

@onready var action_timer: Timer = $ActionTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var block_cooldown_timer: Timer = $BlockCooldownTimer

## Method is checking all states of the CombatComponent and provides feedback regarding the ability to attack.
func can_attack() -> bool:
	return !isPerformingAction and !isDefending and attack_cooldown_timer.is_stopped()

## Method is checking all states of the CombatComponent and provides feedback regarding the ability to block.
func can_block() -> bool:
	return !isPerformingAction and !isDefending and block_cooldown_timer.is_stopped()

func startAction() -> void:
	isPerformingAction = true

func finishAction() -> void:
	if !isManualAction:
		match currentActionType:
			ActionType.ATTACK:
				attack_cooldown_timer.start(attackCooldown)
			ActionType.BLOCK:
				var cooldown := get_randomized_time(blockCooldown, blockCooldownVariance)
				block_cooldown_timer.start(cooldown)
	isPerformingAction = false

func startDefend(manual: bool) -> bool:
	if !can_block():
		return false
	startAction()
	isDefending = true
	isManualAction = manual
	currentActionType = ActionType.BLOCK
	
	if !isManualAction:
		var duration := get_randomized_time(blockDuration, blockDurationVariance)
		action_timer.start(duration)
	return true

func stopDefend() -> void:
	if !isDefending:
		return
		
	isDefending = false
	finishAction()

func setCombatMode(mode: CombatMode) -> void:
	if !isPerformingAction:
		activeCombatMode = mode

func attack(attackName: StringName, manual: bool = false) -> void:
	if !can_attack():
		return
	startAction() #start of the Action geht von der Melee/Range/Mageic Component aus
	isManualAction = manual
	match activeCombatMode:
		CombatMode.MELEE:
			if meleeComponent != null:
				currentActionType = ActionType.ATTACK
				meleeComponent.attack(attackName)
		#CombatMode.RANGED:
			#if rangeComponent != null:
				#rangeComponent.attack()
		CombatMode.MAGIC:
			if magicComponent != null:
				currentActionType = ActionType.ATTACK
				magicComponent.cast_spell(&"Shoot")


## Handles the secondary combat input according to the active combat mode.
func handle_secondary_combat_action(start_action: bool) -> void:
	match activeCombatMode:
		CombatComponent.CombatMode.MELEE:
			if start_action:
				startDefend(true)
			else:
				stopDefend()

		CombatComponent.CombatMode.MAGIC:
			magicComponent.handle_aim_secondary(start_action)

		CombatComponent.CombatMode.RANGED:
			pass
			#_handle_aim_secondary()


## Resolves an incoming damage packet and triggers the corresponding hit reaction.
func getHit(hitType: StringName, damage: DamagePackage) -> void:
	var final_damage := DamageResolver.resolve_damage(damage, defenseComponent, get_active_block_defense())
	
	if healthComponent != null and final_damage > 0.0:
		healthComponent.take_damage(final_damage)
	
	if isDefending:
		character.rig.playReaction(&"BlockHit")
	else:
		cancelCurrentAction()
		character.rig.playReaction(&"Hit")


## Returns active shield block defense while the character is defending.
func get_active_block_defense() -> Array[DefenseData]:
	if !isDefending:
		return []

	var shield : Shield = equipmentComponent.get_active_shield()

	if shield == null:
		return []

	return shield.block_defense


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


func get_randomized_time(base: float, variance: float) -> float:
	return base + randf_range(-variance, variance)

## Update Visual while blocking. lower body parts are animated differently whene moving or standing
func updateCombatVisuals(delta: float, movementSpeedRatio: float) -> void:
	
	if character == null or character.rig == null:
		return
	
	character.rig.defend(delta, isDefending, movementSpeedRatio)


#func _damage_calculation(damage: DamagePackage, shield: DefenseData)-> float:
	#return 0


func _on_cool_down_timer_timeout() -> void:
	pass


func _on_action_timer_timeout() -> void:
	match currentActionType:
		ActionType.BLOCK:
			stopDefend()
