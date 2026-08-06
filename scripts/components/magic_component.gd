class_name MagicComponent
extends Node

@export var combatComponent: CombatComponent
@export var character: CharacterContext
@export var attackSet: AttackSetData

@export var fireball: PackedScene

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

## Shoot a firebal after spellcast "shoot"
func shoot_fireball()-> void:
	var weapon := character.active_weapon

	if weapon == null:
		push_warning("MagicComponent: No active weapon equipped.")
		return
	
	if weapon is not MagicWeapon:
		push_warning("MagicComponent: Active weapon has no projectile spawn point.")
		return
	
	if fireball == null:
		push_error("MagicComponent: Fireball scene is missing.")
		return
	
	var magic_weapon := weapon as MagicWeapon
	var spawn_transform := magic_weapon.get_projectile_spawn_transform()

	var projectile := fireball.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform = spawn_transform


func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.ATTACK_FINISHED:
			finish_spell()
			
		AnimationEventRelay.AnimationEvents.SPAWN_MAGIC_SPELL:
			print("Spawn Fireball")
			shoot_fireball()
