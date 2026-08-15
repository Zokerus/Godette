class_name EquipmentComponent
extends Node

signal equipment_changed


## Notifies character systems that equipped items have changed.
func notify_equipment_changed() -> void:
	equipment_changed.emit()
