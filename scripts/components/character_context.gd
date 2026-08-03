class_name CharacterContext
extends Node

@export_category("Character")
@export var attributes: CharacterAttributes
@export var rig: CharacterRig

const BASE_HEALTH: float = 40.0
const HEALTH_PER_VITALITY: float = 8.0
const HEALTH_PER_ENDURANCE: float = 2.0

const BASE_MANA: float = 20.0
const MANA_PER_INTELLIGENCE: float = 8.0

const BASE_STAMINA: float = 40.0
const STAMINA_PER_ENDURANCE: float = 6.0


## Returns the character's maximum health derived from its primary attributes.
func get_max_health() -> float:
	if attributes == null:
		push_error("CharacterContext: CharacterAttributes are missing.")
		return 0.0

	return (
		BASE_HEALTH
		+ attributes.vitality * HEALTH_PER_VITALITY
		+ attributes.endurance * HEALTH_PER_ENDURANCE
	)
	

## Returns the character's maximum mana derived from its primary attributes.
func get_max_mana() -> float:
	if attributes == null:
		push_error("CharacterContext: CharacterAttributes are missing.")
		return 0.0

	return (
		BASE_MANA
		+ attributes.intelligence * MANA_PER_INTELLIGENCE
	)
	

## Returns the character's maximum stamina derived from its primary attributes.
func get_max_stamina() -> float:
	if attributes == null:
		push_error("CharacterContext: CharacterAttributes are missing.")
		return 0.0

	return (
		BASE_STAMINA
		+ attributes.endurance * STAMINA_PER_ENDURANCE
	)
