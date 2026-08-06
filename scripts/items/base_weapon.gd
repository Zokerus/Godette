class_name BaseWeapon
extends Node3D

## TODO for future puposes
#@export weapon_attributes: WeaponData

var basic_damge: float = 10.0 # might be set by weapon_attributes in the future

## return damage of the weapon, defense and buffs of the target are not included
func get_damage()-> float:
	return basic_damge
