class_name CameraController
extends Node3D

@export var shoulder_pivot: Node3D

@export_category("Camera Offsets")
@export var exploration_offset := Vector3(0.7, 0.2, 0.0)
@export var aim_offset := Vector3(0.9, 0.2, 0.0)
@export var transition_duration: float = 0.2

var camera_tween: Tween


## Smoothly moves the camera into or out of the aiming shoulder position.
func set_aiming(active: bool) -> void:
	var target_offset := aim_offset if active else exploration_offset

	if camera_tween != null:
		camera_tween.kill()

	camera_tween = create_tween()
	camera_tween.tween_property(
		shoulder_pivot,
		"position",
		target_offset,
		transition_duration
	)
