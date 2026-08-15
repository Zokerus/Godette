class_name EquipmentComponent
extends Node

signal equipment_changed

@export var character_root: Node

var equipment_slots: Array[EquipmentSlot] = []


func _ready() -> void:
	if character_root == null:
		push_error("EquipmentComponent: Character root is missing.")
		return
		
	initialize_equipment_slots()
	

## Finds all equipment slots below the character root and connects their change signals.
func initialize_equipment_slots() -> void:
	equipment_slots.clear()
	_find_equipment_slots(character_root)


## Recursively searches a node subtree for equipment slots.
func _find_equipment_slots(node: Node) -> void:
	for child in node.get_children():
		if child is EquipmentSlot:
			var slot := child as EquipmentSlot
			equipment_slots.append(slot)
			
			if !slot.equipment_changed.is_connected(_on_equipment_slot_changed):
				slot.equipment_changed.connect(_on_equipment_slot_changed)

		_find_equipment_slots(child)


## Receives equipment change signal from slots and notifies character systems that equipped items have changed.
func _on_equipment_slot_changed() -> void:
	equipment_changed.emit()
