class_name Projectile
extends Area3D

#TODO type of damage and damage over time

var basic_damage: float = 10.0 # might be set by weapon_attributes in the future
var origin: Vector3

## return damage of the weapon, defense and buffs of the target are not included
func get_damage()-> float:
	return basic_damage
