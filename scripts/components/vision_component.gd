class_name VisionComponent
extends Node3D

signal target_identified(targetObject: Node3D)
signal target_lost()
signal target_died()

@export var excludeParent: bool = true
@export var detectionRange: float = 10.0
@export var FOV_angle: float = 150.0
@export var  rig_yaw_pivot: Node3D
@export var eyeHeight: float = 1.65

var visibleTarget: Node3D = null
var candidates: Array[Node3D] = []
var target_died_callback: Callable

@onready var detection_area_3d: Area3D = $DetectionArea3D
@onready var vision_ray_cast_3d: RayCast3D = $VisionRayCast3D
@onready var collision_shape_3d: CollisionShape3D = $DetectionArea3D/CollisionShape3D



func _ready() -> void:
	collision_shape_3d.shape.set("radius", detectionRange)
	#global_position = global_position + Vector3.UP * eyeHeight


func updateVision() -> void:
	var newTarget : Node3D = null

	for body in candidates:
		if body == null or !is_instance_valid(body):
			continue

		if _canSeeTarget(body):
			newTarget = body
			break
	
	if newTarget != visibleTarget:
		if newTarget != null:
			_set_visible_target(newTarget)
		else:
			target_lost.emit()
			visibleTarget = null


func _canSeeTarget(target: Node3D) -> bool:
	# Set the ray to point at the player; Vector3.UP*1.4 to adjust for chestheight
	vision_ray_cast_3d.target_position = vision_ray_cast_3d.to_local(target.global_position + Vector3.UP * 1.4)
	
	# Optional: Force update if needed more than once per frame
	# ray.force_raycast_update()
	
	var direction_to_target = global_position.direction_to(target.global_position)
	var forward_dir = -rig_yaw_pivot.global_transform.basis.z # Forward is -Z in Godot
	forward_dir.y = 0
	forward_dir = forward_dir.normalized()
	
	#Calculate angle
	var angle = rad_to_deg(forward_dir.angle_to(direction_to_target))
	
	if angle <= FOV_angle/2.0:
		if vision_ray_cast_3d.is_colliding():
			if vision_ray_cast_3d.get_collider() != target:
				return false
			else:
				#target_identified.emit(target)
				return true
		else:
			return false
	else:
		return false

## Registers a newly visible target and observes its lifetime.
func _set_visible_target(new_target: Node3D)-> void:
	_clear_target_connection
	
	if new_target == null:
		return
	
	visibleTarget = new_target
	if visibleTarget.has_signal("died"):
		target_died_callback = _on_target_died.bind(visibleTarget)
		visibleTarget.connect("died", target_died_callback)
		
	target_identified.emit(visibleTarget)


## Disconnects the currently observed target signal.
func _clear_target_connection()-> void:
	if ( visibleTarget != null and is_instance_valid(visibleTarget) 
	and target_died_callback.is_valid() and visibleTarget.is_connected("died", target_died_callback)):
		visibleTarget.disconnect("died", target_died_callback)
	
	target_died_callback = Callable()


## Clears the current target when that character dies.
func _on_target_died(dead_target: Node3D) -> void:
	if dead_target != visibleTarget:
		return

	_clear_visible_target()


## Removes the current target and notifies the AI.
func _clear_visible_target() -> void:
	var previous_target := visibleTarget

	_clear_target_connection()
	visibleTarget = null
	candidates.erase(previous_target)

	target_died.emit()


func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body == self.get_parent():
		return
	
	if body.is_in_group("Player"):
		candidates.append(body)
	
	if candidates.size() > 0:
		vision_ray_cast_3d.enabled = true


func _on_detection_area_3d_body_exited(body: Node3D) -> void:
	candidates.erase(body)
	if candidates.size() <= 0:
		vision_ray_cast_3d.enabled = false
