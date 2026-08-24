class_name Projectile
extends Area3D

#TODO type of damage and damage over time
@export var damage_data: Array[DamageData] = [] # might be set by weapon_attributes in the future

var origin: Vector3
var damage_package: DamagePackage
