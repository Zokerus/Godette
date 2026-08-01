class_name Sword1H
extends Node3D


func _on_hit_box_body_entered(body: Node3D) -> void:
	print("Weapon touched: ", body.name)
