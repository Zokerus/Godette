class_name BaseWeapon
extends Node3D

## TODO for future puposes
#@export weapon_attributes: WeaponData
@export var damage: Array[DamageData] = []

var cached_damage: Array[DamageInstance] = []

## Creates damage data for one concrete hit from the cached weapon damage.
func build_damage_packet(combo_modifier: float = 1.0, critical_modifier: float = 1.0) -> DamagePacket:
	var packet := DamagePacket.new()

	for temp_damage in cached_damage:
		var hit_damage :DamageInstance = temp_damage.duplicate()

		hit_damage.amount *= combo_modifier
		hit_damage.amount *= critical_modifier

		packet.damage_instances.append(hit_damage)

	return packet


## Recalculates the weapon's runtime damage from its base data and character modifiers.
func recalculate_damage(character: CharacterContext) -> void:
	cached_damage.clear()

	for damage_data in damage:
		var damage_instance := DamageInstance.new()

		damage_instance.category = damage_data.category
		damage_instance.type = damage_data.type
		damage_instance.amount = calculate_damage( damage_data, null)

		cached_damage.append(damage_instance)
	
##TODO Placeholder for calculating runtime damage from weapon and characterdata,
## Character has to be defined, because enemies and player are not the same
func calculate_damage(damage_data: DamageData, character: Node3D)-> float:
	return damage_data.amount
