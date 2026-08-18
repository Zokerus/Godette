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
