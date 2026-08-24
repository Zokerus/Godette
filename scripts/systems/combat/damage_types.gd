class_name DamageTypes
extends RefCounted

enum Category {
	PHYSICAL,
	MAGICAL,
}

enum Type {
	NONE,
	SLASH,
	PIERCE,
	BLUNT,
	FIRE,
	ICE,
	LIGHTNING,
	LIGHT,
	DARK,
}

## Returns whether a damage type belongs to the given damage category.
static func is_valid_type(category: Category, type: Type) -> bool:
	match category:
		Category.PHYSICAL:
			return type in [
				Type.NONE,
				Type.SLASH,
				Type.BLUNT,
				Type.PIERCE
			]

		Category.MAGICAL:
			return type in [
				Type.NONE,
				Type.FIRE,
				Type.ICE,
				Type.LIGHTNING,
				Type.LIGHT,
				Type.DARK
			]
		
	return false
