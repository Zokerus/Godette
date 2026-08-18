class_name Shield
extends Equipment

@export var defense: Array[DefenseData] = []


## return defense values of the item (shield)
func get_defense()-> Array[DefenseData]:
	return defense
