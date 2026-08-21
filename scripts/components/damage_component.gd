class_name DamageComponent
extends Node

@export var character: CharacterContext
@export var equipment_component: EquipmentComponent

var category_modifiers: Dictionary = {}
var type_modifiers: Dictionary = {}


func _ready() -> void:
	equipment_component.equipment_changed.connect(_on_combat_values_changed)


## Recalculates damage modifiers and all dependent runtime damage values.
func _on_combat_values_changed() -> void:
	recalculate_damage_modifiers()
	#recalculate_weapon_damage()


## Recalculates all cached damage modifiers from character attributes, equipment and buffs.
func recalculate_damage_modifiers() -> void:
	category_modifiers.clear()
	type_modifiers.clear()

	_recalculate_attribute_modifiers()
	_recalculate_equipment_modifiers()
	_recalculate_buff_modifiers()


## Recalculates the active weapon's cached runtime damage.
func recalculate_weapon_damage() -> void:
	var weapon := equipment_component.get_active_weapon()
	if weapon == null:
		return
		
	weapon.cached_damage.clear()

	for damage in weapon.damage_data:
		weapon.cached_damage.append(calculate_damage(damage))
	
## Creates a runtime damage instance using cached category and type modifiers.
func calculate_damage(damage_data: DamageData) -> DamageInstance:
	assert(DamageTypes.is_valid_type(damage_data.category, damage_data.type))
	
	var category_modifier: float = category_modifiers.get( damage_data.category, 0.0)
	var type_modifier: float = type_modifiers.get(damage_data.type, 0.0)
	
	var damage_instance := DamageInstance.new()
	damage_instance.category = damage_data.category
	damage_instance.type = damage_data.type
	damage_instance.amount = damage_data.amount * (1.0 + category_modifier + type_modifier)
	
	return damage_instance


## Builds a damage package from spell base damage using cached damage modifiers.
func build_spell_package(spell_damage: Array[DamageData]) -> DamagePackage:
	var package := DamagePackage.new()

	for damage_data in spell_damage:
		package.damage_instances.append(calculate_damage(damage_data))

	return package


## Adds all damage modifiers provided by the currently equipped items.
func _recalculate_equipment_modifiers() -> void:
	var equipment := equipment_component.get_equipped_items()

	for item in equipment:
		for modifier in item.damage_modifiers:
			match modifier.scope:
				DamageModifier.Scope.CATEGORY:
					_add_category_modifier(modifier.category, modifier.amount)

				DamageModifier.Scope.TYPE:
					_add_type_modifier(modifier.type, modifier.amount)


## Adds damage modifiers derived from the character's attributes.
func _recalculate_attribute_modifiers() -> void:
	pass


## Adds all currently active damage modifiers from buffs.
func _recalculate_buff_modifiers() -> void:
	pass


## Adds a damage modifier to the specified damage category.
func _add_category_modifier(category: DamageTypes.Category, amount: float) -> void:
	category_modifiers[category] = category_modifiers.get(category, 0.0) + amount


## Adds a damage modifier to the specified damage type.
func _add_type_modifier(type: DamageTypes.Type, amount: float) -> void:
	type_modifiers[type] = type_modifiers.get(type, 0.0) + amount
