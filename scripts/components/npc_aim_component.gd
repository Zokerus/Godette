class_name NPCAimComponent
extends AimComponent

@export var vision_component: VisionComponent
@export var target_height: float = 1.4 ##TODO Use HeadMarker or TargetMarker?


## Returns the aiming direction toward the NPC's currently visible target.
func get_aim_direction(origin: Vector3) -> Vector3:
	## Distance and visibility are already checked inside VisionComponent
	if vision_component == null:
		return Vector3.ZERO
	var target := vision_component.visibleTarget
	if target == null or not is_instance_valid(target):
		return Vector3.ZERO
	
	var aim_point := target.global_position + Vector3.UP * target_height
	
	return origin.direction_to(aim_point)
