class_name DamageModifier
extends RefCounted

enum Scope {
	CATEGORY,
	TYPE
}

var scope: Scope
var category: DamageTypes.Category
var type: DamageTypes.Type
var amount: float = 0.0
