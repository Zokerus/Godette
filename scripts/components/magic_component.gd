class_name MagicComponent
extends Node

@export var combatComponent: CombatComponent
@export var characterRig: CharacterRig

func cast_spell() -> void:
	if combatComponent == null or characterRig == null:
		return
	
	if combatComponent.activeCombatMode != CombatComponent.CombatMode.MAGIC:
		return
	
	if combatComponent.isPerformingAction:
		return
	
	characterRig.castSpell("Shoot")
	
