class_name BaseWeapon
extends Equipment

## TODO for future puposes
#@export weapon_attributes: WeaponData

var cached_damage: Array[DamageInstance] = []

## Creates damage data for one concrete hit from the cached weapon damage.
func build_damage_packet(combo_modifier: float = 1.0, critical_modifier: float = 1.0) -> DamagePackage:
	var packet := DamagePackage.new()

	for temp_damage in cached_damage:
		var hit_damage :DamageInstance = temp_damage.duplicate()

		hit_damage.amount *= combo_modifier
		hit_damage.amount *= critical_modifier

		packet.damage_instances.append(hit_damage)

	return packet
