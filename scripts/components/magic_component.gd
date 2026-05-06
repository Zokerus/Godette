class_name MagicComponent
extends Node

@export var combatComponent: CombatComponent
@export var character: CharacterContext

func cast_spell() -> void:
	if combatComponent == null or character.rig == null:
		return
	
	if combatComponent.activeCombatMode != CombatComponent.CombatMode.MAGIC:
		return
	
	if combatComponent.isPerformingAction:
		return
	
	character.rig.castSpell("Shoot")
	
