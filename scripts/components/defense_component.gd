class_name DefenseComponent
extends Node


@export var character: CharacterContext
@export var equipment_component: EquipmentComponent
##TODO Equipment

var category_resistances: Dictionary = {}
var type_resistances: Dictionary = {}


func _ready() -> void:
	equipment_component.equipment_changed.connect(recalculate_defense)
	#buff_component.buffs_changed.connect(recalculate_defense)
	#attributes.attributes_changed.connect(recalculate_defense)

## Rebuilds all cached defense values from character attributes, equipment and buffs.
func recalculate_defense() -> void:
	category_resistances.clear()
	type_resistances.clear()

	#_apply_character_defense()
	_recalculate_equipment_defense()
	#_apply_buff_defense()


## Adds a resistance value for the given damage category.
func add_category_resistance(category: DamageTypes.Category, value: float) -> void:
	category_resistances[category] = category_resistances.get(category, 0.0) + value


## Adds a resistance value for the given damage type.
func add_type_resistance(type: DamageTypes.Type, value: float) -> void:
	type_resistances[type] = type_resistances.get(type, 0.0) + value


## Returns the cached resistance for the given damage category.
func get_category_resistance(category: DamageTypes.Category) -> float:
	return category_resistances.get(category, 0.0)


## Returns the cached resistance for the given damage type.
func get_type_resistance(type: DamageTypes.Type) -> float:
	return type_resistances.get(type, 0.0)


func _recalculate_equipment_defense() -> void:
	var equipment := equipment_component.get_equipped_items()
	for item in equipment:
		if item is BaseWeapon:
			continue
		for defense in item.get_defense():
			add_category_resistance(defense.category, defense.amount)
			if defense.type != DamageTypes.Type.NONE:
				add_type_resistance(defense.type, defense.amount)
