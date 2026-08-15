class_name DamageComponent
extends Node

@export var character: CharacterContext
## Store the active weapon inside here?

## Recalculates the weapon's runtime damage from its base data and character modifiers.
func recalculate_damage(character: CharacterContext) -> void:
	var weapon := character.active_weapon
	if weapon == null: ##TODO Set damage to zero, but fpr the time being fine
		return
	weapon.cached_damage.clear()

	for damage_data in weapon.damage:
		var damage_instance := DamageInstance.new()

		damage_instance.category = damage_data.category
		damage_instance.type = damage_data.type
		damage_instance.amount = calculate_damage( damage_data, null)

		weapon.cached_damage.append(damage_instance)
	
##TODO Placeholder for calculating runtime damage from weapon and characterdata,
## Character has to be defined, because enemies and player are not the same
func calculate_damage(damage_data: DamageData, _character: Node3D)-> float:
	return damage_data.amount
