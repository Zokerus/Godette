class_name Shield
extends Node3D

@export var defense: Array[DefenseData] = []


## return defense values of the item (shield)
func get_defense()-> Array[DefenseData]:
	return defense
