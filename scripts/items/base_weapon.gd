class_name BaseWeapon
extends Node3D

## TODO for future puposes
#@export weapon_attributes: WeaponData
@export var damage: Array[DamageData] = []

## return damage of the weapon, defense and buffs of the target are not included
func get_damage()-> Array[DamageData]:
	return damage
