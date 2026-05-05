extends Node
class_name MeleeComponent

@export var combatComponent: CombatComponent
@export var characterRig: CharacterRig
@export var comboWindowTime := 0.5

@onready var comboTimer: Timer = $ComboTimer

var comboWindowOpen := false
var currentComboIndex := 0

var attacks: Array[StringName] = [
	&"Chop",
	&"Slice"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	comboTimer.wait_time = comboWindowTime

func attack() -> void:
	if combatComponent == null or characterRig == null:
		return
	
	if combatComponent.activeCombatMode != CombatComponent.CombatMode.MELEE:
		return
	
	if combatComponent.isPerformingAction:
		if comboWindowOpen:
			_playNextComboAttack()
		return
	
	if combatComponent.canStartAction():
		_startFirstAttack()

func _startFirstAttack()-> void:
	currentComboIndex = 0
	comboWindowOpen = false
	
	combatComponent.startAction()
	characterRig.playAttack(attacks[currentComboIndex])

func _playNextComboAttack()-> void:
	comboWindowOpen = false
	comboTimer.stop()
	
	currentComboIndex += 1
	
	if currentComboIndex > attacks.size():
		return
	
	characterRig.playAttack(attacks[currentComboIndex])
	
func openComboWindow() -> void:
	if !combatComponent.isPerformingAction:
		return
	
	comboWindowOpen = true
	comboTimer.start()

func finishAttack()-> void:
	comboWindowOpen = false
	comboTimer.stop()
	currentComboIndex = 0
	combatComponent.finishAction()

func _onAnimationEventReceived(eventName: StringName) -> void:
	match eventName:
		&"combo_window_open":
			openComboWindow()
		&"attack_finished":
			finishAttack()

func _on_combo_timer_timeout() -> void:
	pass # Replace with function body.
