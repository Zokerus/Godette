class_name MeleeComponent
extends Node

@export var combatComponent: CombatComponent
@export var character: CharacterContext
@export var attackSet: AttackSetData
@export var comboWindowTime := 0.5

var comboWindowOpen := false
var currentComboIndex := 0

@onready var comboTimer: Timer = $ComboTimer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	comboTimer.wait_time = comboWindowTime

func attack() -> void:
	if combatComponent == null or character.rig == null:
		return
	
	if combatComponent.activeCombatMode != CombatComponent.CombatMode.MELEE:
		return
	
	if combatComponent.isPerformingAction:
		if comboWindowOpen:
			_playNextComboAttack()
		return
	
	if comboWindowOpen:
		_playNextComboAttack()
		return
	
	if combatComponent.canStartAction():
		_startFirstAttack()

func _startFirstAttack()-> void:
	currentComboIndex = 0
	comboWindowOpen = false
	
	combatComponent.startAction()
	character.rig.playAttack(attackSet.attacks[currentComboIndex])

func _playNextComboAttack()-> void:
	comboWindowOpen = false
	comboTimer.stop()
	
	currentComboIndex += 1
	
	if currentComboIndex >= attackSet.attacks.size():
		return
	
	character.rig.playAttack(attackSet.attacks[currentComboIndex])
	
func openComboWindow() -> void:
	if !combatComponent.isPerformingAction:
		return
	
	comboWindowOpen = true
	comboTimer.start()

func finishAttack()-> void:
	combatComponent.finishAction()
	

func cancelAttack() -> void:
	comboTimer.stop()
	comboWindowOpen = false
	currentComboIndex = 0
	finishAttack()

func _onAnimationEventReceived(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.COMBO_WINDOW_OPEN:
			openComboWindow()
		AnimationEventRelay.AnimationEvents.ATTACK_FINISHED:
			finishAttack()

func _on_combo_timer_timeout() -> void:
	comboWindowOpen = false
	currentComboIndex = 0
