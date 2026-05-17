extends Enemy


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	vision_component.updateVision()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	
	match state_component.currentState:
		EnemyState.IDLE:
			handle_idle(delta)
		
		EnemyState.CHASE:
			handle_chase(delta)
		
		EnemyState.ATTACK_PREPARE:
			handle_attack_prepare(delta)
		
		EnemyState.SEARCH:
			handle_search(delta)


func get_movement_direction() -> Vector3:
	var destination := navigation_agent_3d.get_next_path_position()
	var direction := global_position.direction_to(destination)
	return direction.normalized()


func handle_movement(delta: float) -> void:
	#var is_running: bool = Input.is_action_pressed("run")
	var speed : float = 2.0
	
	if navigation_agent_3d.is_navigation_finished(): 
		velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
		character.rig.travel("Idle_A")
		return
	
	var direction := get_movement_direction() 
	look_toward_direction(direction, delta)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	character.rig.travel("Running_A")
	
		#movementSpeedRatio = clampf(Vector3(velocity.x, 0, velocity.z).length() / speed, 0.0, 1.0)
	move_and_slide()


func stop_movement(delta) -> void:
	velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
	velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
	character.rig.travel("Idle_A")
	move_and_slide()


func look_toward_direction(direction: Vector3, delta: float)-> void:
	var target_transform:= rig_yaw_pivot.global_transform.looking_at(rig_yaw_pivot.global_position - direction, Vector3.UP, true)
	
	rig_yaw_pivot.global_transform = rig_yaw_pivot.global_transform.interpolate_with(target_transform,  1.0 - exp(-10 * delta))


func update_navigation(destination: Vector3) -> void:
	navigation_agent_3d.target_position = destination


func handle_idle(delta: float) -> void:
	stop_movement(delta)


func handle_chase(delta: float) -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	#enemy is still attack and must not move
	if combat_component.isPerformingAction:
		stop_movement(delta)
		return
		
	
	var distance := global_position.distance_to(target.global_position)
	
	if distance <= attackRange:
		stop_movement(delta)
		if combat_component.canStartAction():
			state_component.change_state(EnemyState.ATTACK_PREPARE)
		return
	
	update_navigation(target.global_position)
	handle_movement(delta)


func handle_attack_prepare(delta: float) -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	#Ggf Übergang zu SEARCH
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	var distance := global_position.distance_to(target.global_position)
	# target is to far away, cancel attack and follow
	if distance > attackRange * attackPrepareCancelRangeMultiplier:
		prepare_timer.stop()
		state_component.change_state(EnemyState.CHASE)
		return
	
	update_navigation(target.global_position)
	
	var direction := global_position.direction_to(target.global_position)
	direction.y = 0.0
	look_toward_direction(direction.normalized(), delta)
	
	# Bewegung optional:
	if distance <= attackRange:
		stop_movement(delta)
	else:
		handle_movement(delta)


func handle_search(delta) -> void:
	update_navigation(lastKnownPosition)
	handle_movement(delta)
	
	if navigation_agent_3d.is_navigation_finished():
		state_component.change_state(EnemyState.IDLE)
