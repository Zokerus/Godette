class_name EquipmentSlot
extends Node3D

enum SlotType {
	MAIN_HAND,
	OFF_HAND,
	HEAD,
	CHEST,
	RING,
}

signal equipment_changed()

@export var slot_type: SlotType

var equipped_item : Equipment

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exiting)
	_refresh_equipped_item()


## Updates the slot's equipped item from its current scene children.
func _refresh_equipped_item() -> void:
	equipped_item = null

	for child in get_children():
		if child is Equipment: #have to adjusted to parent classes
			equipped_item = child
			break

## Returns the item currently equipped in this slot.
func get_equipped_item() -> Equipment:
	return equipped_item


func _on_child_entered(child: Node) -> void:
	if child is Equipment:
		equipped_item = child as Equipment
		equipment_changed.emit()
		#TODO If child is not a Equipment, it should me moved or removed from tree. Equipmentslot is for Equipment


func _on_child_exiting(child: Node) -> void:
	if child != equipped_item:
		return

	equipped_item = null
	equipment_changed.emit()
