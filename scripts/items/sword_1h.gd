class_name Sword1H
extends Node3D

@onready var hit_box: Area3D = $HitBox
@onready var collision_shape_3d: CollisionShape3D = $HitBox/CollisionShape3D


func _on_hit_box_body_entered(body: Node3D) -> void:
	print("Weapon touched: ", body.name)


func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.ACTIVATE_WEAPON_HITBOX:
			collision_shape_3d.disabled = false
			hit_box.monitoring = true
			print("Weapon Hitbox activated")
		
		AnimationEventRelay.AnimationEvents.DEACTIVATE_WEAPON_HITBOX:
			hit_box.monitoring = false
			collision_shape_3d.disabled = true
			print("Weapon Hitbox deactivated")
