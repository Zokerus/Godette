class_name DamageInstance
extends RefCounted

var amount: float
var category: DamageTypes.Category
var type: DamageTypes.Type


## Creates an independent runtime copy of this damage instance.
func copy() -> DamageInstance:
	var instance := DamageInstance.new()
	instance.amount = amount
	instance.category = category
	instance.type = type
	return instance
