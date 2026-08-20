class_name DamageComponent
extends Node

@export var character: CharacterContext
@export var equipment_component: EquipmentComponent
## Store the active weapon inside here?


func _ready() -> void:
	equipment_component.equipment_changed.connect(recalculate_damage)
	#buff_component.buffs_changed.connect(recalculate_damage)
	#attributes.attributes_changed.connect(recalculate_damage)


## Recalculates the weapon's runtime damage from its base data and character modifiers.
func recalculate_damage() -> void:
	var weapon := equipment_component.get_active_weapon()
	if weapon == null: ##TODO Set damage to zero, but fpr the time being fine
		return
	weapon.cached_damage.clear()

	for damage in weapon.damage_data:
		var damage_instance := DamageInstance.new()

		damage_instance.category = damage.category
		damage_instance.type = damage.type
		damage_instance.amount = calculate_damage(damage, null)

		weapon.cached_damage.append(damage_instance)
	
##TODO Placeholder for calculating runtime damage from weapon and characterdata,
## Character has to be defined, because enemies and player are not the same
func calculate_damage(damage_data: DamageData, _character: Node3D)-> float:
	return damage_data.amount


## Builds runtime damage for a spell from cached weapon damage and spell base data.
func calculate_spell_damage(spell_damage: DamageData, cached_damage: Array[DamageInstance]) -> float:
	var modifier: float = 0.0
	
	for damage in cached_damage:
		if damage.category == spell_damage.category:
			modifier += damage.amount
			
		if damage.type == spell_damage.type:
			modifier += damage.amount
			
	return spell_damage.amount * (1.0 + (modifier/100.0))


## Builds a damage package by combining cached weapon damage with spell damage.
func build_spell_package(weapon: BaseWeapon, spell_damage: Array[DamageData]) -> DamagePackage:
	var package := DamagePackage.new()

	for damage_data in spell_damage:
		var damage := DamageInstance.new()
		damage.category = damage_data.category
		damage.type = damage_data.type
		damage.amount = calculate_spell_damage(damage_data, weapon.cached_damage)

		package.damage_instances.append(damage)

	return package
