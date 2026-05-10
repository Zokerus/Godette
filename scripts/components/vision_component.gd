class_name VisionComponent
extends Node3D

signal target_identified(target: Node3D)

@export var excludeParent: bool = true
@export var FOV_angle: float = 150.0

@onready var detection_area_3d: Area3D = $DetectionArea3D
@onready var vision_ray_cast_3d: RayCast3D = $VisionRayCast3D


var visibleTarget: Node3D = null
var candidates: Array[Node3D] = []

func updateVision() -> void:
	visibleTarget = null

	for body in candidates:
		if body == null or !is_instance_valid(body):
			continue

		if _canSeeTarget(body):
			visibleTarget = body
			return

func _canSeeTarget(target: Node3D) -> bool:
	# Set the ray to point at the player
	vision_ray_cast_3d.target_position = target.global_position - vision_ray_cast_3d.global_position
	
	# Optional: Force update if needed more than once per frame
	# ray.force_raycast_update()
	
	var direction_to_target = global_position.direction_to(target.global_position)
	var forward_dir = global_transform.basis.z # Forward is -Z in Godot
	
	#Calculate angle
	var angle = rad_to_deg(forward_dir.angle_to(direction_to_target))
	
	if angle <= FOV_angle/2.0:
		if vision_ray_cast_3d.is_colliding():
			if vision_ray_cast_3d.get_collider() != target:
				return false
			else:
				print("Player in line of sight!")
				target_identified.emit(target)
				return true
		else:
			return false
	else:
		return false

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body == self.get_parent():
		return
	
	if body.is_in_group("Player"):
		candidates.append(body)


func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	candidates.erase(body)
