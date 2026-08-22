class_name DamageResolver
extends RefCounted

const MIN_RESISTANCE: float = -1.0
const MAX_RESISTANCE: float = 0.9


## Resolves all damage instances against the target's cached (active and passive) defenses.
static func resolve_damage(package: DamagePackage, defense: DefenseComponent, block_defense: Array[DefenseData] = []) -> DamageResult:
	var result:= DamageResult.new()
	result.was_blocked = false
	
	for damage in package.damage_instances:
		var temp = DamageResult.new()
		temp = _resolve_damage_instance(damage, defense, block_defense)
		result.final_damage += temp.final_damage
		result.was_blocked = result.was_blocked or temp.was_blocked
	
	result.final_damage = maxf(result.final_damage, 0.0)
	
	return result


## Resolves one damage instance against matching category and type resistances.
static func _resolve_damage_instance(damage: DamageInstance, defense: DefenseComponent, block_defense: Array[DefenseData]) -> DamageResult:
	var remaining_damage := damage.amount
	var result = DamageResult.new()
	result.was_blocked = false
	
	# 1. Active block
	var block_resistance = _get_block_resistance(damage, block_defense)
	block_resistance = clampf(block_resistance, 0.0, 1.0)
	remaining_damage *= (1.0 - block_resistance)
	if remaining_damage < damage.amount:
		result.was_blocked = result.was_blocked or true
	
	# 2. Passive defense
	var resistance := defense.get_category_resistance(damage.category)
	
	if damage.type != DamageTypes.Type.NONE:
		resistance += defense.get_type_resistance(damage.type)
	
	resistance = clampf(resistance, MIN_RESISTANCE, MAX_RESISTANCE)
	result.final_damage = remaining_damage * (1.0 - resistance)
	
	return result

## Returns the active block resistance matching the incoming damage category and type.
static func _get_block_resistance(damage: DamageInstance, block_defense: Array[DefenseData]) -> float:
	var block_resistance := 0.0

	for block in block_defense:
		if block.category != damage.category:
			continue
		
		if block.type != DamageTypes.Type.NONE and block.type != damage.type:
			continue
		
		block_resistance += block.amount
	
	return block_resistance
