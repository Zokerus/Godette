class_name EquipmentComponent
extends Node

signal equipment_changed ##may be not relevant

@export var character_rig: CharacterRig

var equipment_slots: Array[EquipmentSlot] = []
var main_hand_slot: EquipmentSlot


func _ready() -> void:
	if character_rig == null:
		push_error("EquipmentComponent: Character root is missing.")
		return
	
	initialize_equipment_slots() # connect signals and add slot to slot array
	
	call_deferred("_on_equipment_slot_changed")


## Finds all equipment slots below the character root and connects their change signals.
func initialize_equipment_slots() -> void:
	equipment_slots.clear()
	_find_equipment_slots(character_rig)


## Returns all items currently equipped by the character.
func get_equipped_items() -> Array[Equipment]:
	var equipped_items: Array[Equipment] = []

	for slot in equipment_slots:
		var item := slot.get_equipped_item()

		if item != null:
			equipped_items.append(item)

	return equipped_items


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


## Returns the currently equipped item in the requested slot type.
func get_equipment_slot(slot_type: EquipmentSlot.SlotType) -> EquipmentSlot:
	for slot in equipment_slots:
		if slot.slot_type == slot_type:
			return slot

	return null


##Return active weapon on main hand slot
func get_active_weapon()-> BaseWeapon:
	return main_hand_slot.get_equipped_item() as BaseWeapon
