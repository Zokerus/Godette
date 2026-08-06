class_name ProjectileWeapon
extends BaseWeapon

@export var projectile_spawn_marker: Marker3D


## Returns the global transform used to spawn a projectile.
func get_projectile_spawn_transform() -> Transform3D:
	if projectile_spawn_marker == null:
		push_error("%s: Projectile spawn marker is missing." % name)
		return global_transform

	return projectile_spawn_marker.global_transform
