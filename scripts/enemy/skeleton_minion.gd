class_name SkeletonMinion
extends Enemy


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_poistion := Vector3.ZERO
		random_poistion.x = randf_range(-24.0, 24.0)
		random_poistion.y = randf_range(-24.0, 24.0)
		navigation_agent_3d.target_position = random_poistion

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	
	if !navigation_agent_3d.is_navigation_finished():
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - global_position
		#local_destination.y = 0.0
		var direction = local_destination.normalized()
		
		velocity.x = direction.x * 5.0
		velocity.z = direction.z * 5.0
		move_and_slide()
