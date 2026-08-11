class_name PlayerComponent
extends AimComponent

signal aiming_changed(active: bool)

@export var camera: Camera3D
@export var aim_distance: float = 100.0

var is_aiming: bool = false


## Changes the current aiming state and notifies dependent systems.
func set_aiming(active: bool) -> void:
	if is_aiming == active:
		return

	is_aiming = active
	aiming_changed.emit(active)


## Returns the projectile direction toward the center of the player's camera view.
func get_aim_direction(origin: Vector3) -> Vector3:
	if camera == null:
		return Vector3.ZERO

	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5

	var ray_origin := camera.project_ray_origin(viewport_center)
	var ray_direction := camera.project_ray_normal(viewport_center)

	var aim_point := ray_origin + ray_direction * aim_distance

	return origin.direction_to(aim_point)
