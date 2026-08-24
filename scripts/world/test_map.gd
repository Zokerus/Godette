extends Node3D

@onready var projectilesContainer: Node = $Projectiles


func _ready() -> void:
	ProjectileSpawner.register_projectile_container(projectilesContainer)
