class_name DamagePacket
extends RefCounted

var components: Array[DamageInstance] = []
var source: Node3D
var hit_position: Vector3
var is_critical: bool = false
