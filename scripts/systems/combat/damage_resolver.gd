class_name DamageResolver
extends RefCounted

const MIN_RESISTANCE: float = -1.0
const MAX_RESISTANCE: float = 0.9


## Resolves all damage instances against the target's cached defenses.
static func resolve_damage(package: DamagePackage, defense: DefenseComponent) -> float:
	var total_damage := 0.0
	
	for damage in package.damage_instances:
		total_damage += _resolve_damage_instance(damage, defense)
	
	return maxf(total_damage, 0.0)


## Resolves one damage instance against matching category and type resistances.
static func _resolve_damage_instance(damage: DamageInstance, defense: DefenseComponent) -> float:
	var category_resistance := defense.get_category_resistance(damage.category)
	var type_resistance := 0.0
	
	if damage.type != DamageTypes.Type.NONE:
		type_resistance = defense.get_type_resistance(damage.type)

	var total_resistance := clampf(category_resistance + type_resistance, MIN_RESISTANCE, MAX_RESISTANCE)

	return damage.amount * (1.0 - total_resistance)
