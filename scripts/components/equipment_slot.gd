class_name EquipmentSlot
extends Node3D

enum SlotType {
	MAIN_HAND,
	OFF_HAND,
	HEAD,
	CHEST,
	RING,
}

signal equipment_changed(slot: EquipmentSlot)

@export var slot_type: SlotType

var equipped_item : Node3D

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exiting)


## Returns the item currently equipped in this slot.
func get_equipped_item() -> Node:
	return equipped_item


func _on_child_entered(child: Node) -> void:
	equipped_item = child
	equipment_changed.emit(self)


func _on_child_exiting(child: Node) -> void:
	if child != equipped_item:
		return

	equipped_item = null
	equipment_changed.emit(self)
