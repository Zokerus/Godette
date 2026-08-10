extends Node

var projectile_container: Node

## Registers the node that receives newly spawned projectiles.
func register_projectile_container(container: Node) -> void:
	projectile_container = container
	
## Creates a projectile in the active world and returns the instance.
func spawn_projectile(projectile_scene: PackedScene, spawn_transform: Transform3D) -> Node3D:
	if projectile_container == null:
		push_error("ProjectileSpawner: No projectile container registered.")
		return null

	var projectile := projectile_scene.instantiate() as Node3D
	projectile_container.add_child(projectile)
	projectile.global_transform = spawn_transform

	return projectile
