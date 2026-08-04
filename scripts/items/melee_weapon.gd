class_name MeleeWeapon
extends Node3D

var hit_bodies: Array[Node3D] = []
var basic_damge: float = 10.0

@onready var hit_box: Area3D = $HitBox
@onready var collision_shape_3d: CollisionShape3D = $HitBox/CollisionShape3D


## Enables the weapon hitbox during the active attack window.
func enable_hitbox() -> void:
	hit_bodies.clear()
	collision_shape_3d.set_deferred("disabled", false)
	hit_box.set_deferred("monitoring", true)
	
	#wait for the next physics frame
	await get_tree().physics_frame

	if not hit_box.monitoring:
		return

	for body in hit_box.get_overlapping_bodies():
		_process_hit(body)


## Disables the weapon hitbox outside the active attack window.
func disable_hitbox() -> void:
	hit_box.set_deferred("monitoring", false)
	collision_shape_3d.set_deferred("disabled", true)


func _process_hit(body: Node3D):
		#body got damage on this try, deal damage just once
		if body in hit_bodies:
			return
		
		var combat_component := body.get_node_or_null("CombatComponent") as CombatComponent
		if combat_component == null:
			return
			
		hit_bodies.append(body)
		combat_component.getHit(&"LightHit", get_damage())

## return damage of the weapon, defense and buffs of the target are not included
func get_damage()-> float:
	return basic_damge


func _on_hit_box_body_entered(body: Node3D) -> void:
			_process_hit(body)
