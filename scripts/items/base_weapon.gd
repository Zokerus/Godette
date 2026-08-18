class_name BaseWeapon
extends Equipment

## TODO for future puposes
#@export weapon_attributes: WeaponData

var cached_damage: Array[DamageInstance] = []

## Creates damage data for one concrete hit from the cached weapon damage.
func build_damage_package(combo_modifier: float = 1.0, critical_modifier: float = 1.0) -> DamagePackage:
	var package := DamagePackage.new()

	for temp_damage in cached_damage:
		var hit_damage :DamageInstance = temp_damage.copy()

		hit_damage.amount *= combo_modifier
		hit_damage.amount *= critical_modifier

		package.damage_instances.append(hit_damage)

	return package
