class_name DamagePackage
extends RefCounted

var damage_instances: Array[DamageInstance] = []
var source: Node3D
var hit_position: Vector3
var is_critical: bool = false
