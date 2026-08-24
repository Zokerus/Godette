class_name Equipment
extends Node3D

@export var damage_data: Array[DamageData] = []
@export var defense_data: Array[DefenseData] = []
@export var damage_modifiers: Array[DamageModifier] = []

## return defense values of the item (shield)
func get_defense()-> Array[DefenseData]:
	return defense_data
