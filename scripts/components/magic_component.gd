class_name MagicComponent
extends Node

@export var combatComponent: CombatComponent
@export var character: CharacterContext
@export var attackSet: AttackSetData

func cast_spell(_attackName: StringName) -> void:
	if combatComponent == null or character.rig == null:
		return
	
	if combatComponent.activeCombatMode != CombatComponent.CombatMode.MAGIC:
		return
	
	if combatComponent.can_attack():
		return
	
	character.rig.castSpell("Shoot")


func finish_spell()-> void:
	combatComponent.finishAction()


func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.ATTACK_FINISHED:
			finish_spell()
			
		AnimationEventRelay.AnimationEvents.SPAWN_MAGIC_SPELL:
			print("Spawn Fireball")
