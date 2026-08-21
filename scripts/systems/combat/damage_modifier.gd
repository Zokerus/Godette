class_name DamageModifier
extends Resource

enum Scope {
	CATEGORY,
	TYPE
}

@export var scope: Scope
@export var category: DamageTypes.Category
@export var type: DamageTypes.Type
@export var amount: float = 0.0
