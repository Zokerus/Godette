class_name HealthComponent
extends Node


signal health_changed(current_health: float, max_health: float)
signal died


@export var character: CharacterContext

var current_health: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if character == null:
		push_error("HealthComponent: CharacterContext is missing.")
		return

	current_health = character.get_max_health()


## Applies damage and returns the amount of health actually removed.
func take_damage(amount: float) -> float:
	if amount <= 0.0 or current_health <= 0.0:
		return 0.0

	var previous_health := current_health
	current_health = maxf(current_health - amount, 0.0)

	health_changed.emit(current_health, get_max_health())

	if current_health <= 0.0:
		died.emit()

	return previous_health - current_health


## Returns the character's currently calculated maximum health.
func get_max_health() -> float:
	if character == null:
		return 0.0

	return character.get_max_health()
	

## Heals damage and returns the amount of health actually regained.
func heal(amount: float) -> float:
	if amount <= 0.0 or current_health <= 0.0:
		return 0.0

	var previous_health := current_health
	current_health = minf(current_health + amount, get_max_health())

	health_changed.emit(current_health, get_max_health())

	return  current_health - previous_health


## Debug function to print current health after change
func _on_health_changed(current_health: float, max_health: float) -> void:
	print("[Health]\n","Current: ", current_health, "/", max_health, "\n", "Damage: ", max_health- current_health)
