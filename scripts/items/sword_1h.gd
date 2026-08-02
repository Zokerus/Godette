class_name Sword1H
extends Node3D

var hit_bodies: Array[CharacterBody3D] = []

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


func _process_hit(body: CharacterBody3D):
		#body got damage on this try, deal damage just once
		if body in hit_bodies:
			return
		
		hit_bodies.append(body)
		
		var combat_component := body.get_node_or_null("CombatComponent") as CombatComponent
		if combat_component == null:
			return
			
		combat_component.getHit(&"LightHit")
		
		#TODO set HIT Animation name
		body.combat_component.getHit("test")


func _on_hit_box_body_entered(body: Node3D) -> void:
		_process_hit(body)


#func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	#match event:
		#AnimationEventRelay.AnimationEvents.ACTIVATE_WEAPON_HITBOX:
			#collision_shape_3d.disabled = false
			#hit_box.monitoring = true
			#print("Weapon Hitbox activated")
		#
		#AnimationEventRelay.AnimationEvents.DEACTIVATE_WEAPON_HITBOX:
			#hit_box.monitoring = false
			#collision_shape_3d.disabled = true
			#print("Weapon Hitbox deactivated")
