class_name SkeletonMinion
extends Enemy

var target: Node3D

@onready var melee_component: MeleeComponent = $MeleeComponent


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-24.0, 24.0)
		random_position.y = randf_range(-24.0, 24.0)
		navigation_agent_3d.target_position = random_position


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
			
		EnemyState.ATTACK:
			handle_attack()
			
		EnemyState.RECOVER:
			#currently nothing to handle except for timer.timeout -> signal
			pass
	
	#handle_movement(delta)
	#
	#move_and_slide()


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


func look_toward_direction(direction: Vector3, delta: float)-> void:
	var target_transform:= rig_yaw_pivot.global_transform.looking_at(rig_yaw_pivot.global_position - direction, Vector3.UP, true)
	
	rig_yaw_pivot.global_transform = rig_yaw_pivot.global_transform.interpolate_with(target_transform,  1.0 - exp(-10 * delta))


func update_navigation(destination: Vector3) -> void:
	navigation_agent_3d.target_position = destination


func handle_idle(delta: float) -> void:
	handle_movement(delta)


func handle_chase(delta: float) -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	var distance := global_position.distance_to(target.global_position)
	
	if distance <= attackRange:
		stop_movement(delta)
		state_component.change_state(EnemyState.ATTACK_PREPARE)
		return
	
	update_navigation(target.global_position)
	handle_movement(delta)


func handle_attack_prepare(delta: float) -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	var direction := global_position.direction_to(target.global_position)
	direction.y = 0.0
	direction = direction.normalized()
	look_toward_direction(direction, delta)


func handle_attack() -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	if combat_component.canStartAction():
		combat_component.attack()


func _on_vision_component_target_identified(object: Node3D) -> void:
	target = object
	state_component.change_state(EnemyState.CHASE)


func _on_prepare_timer_timeout() -> void:
	state_component.change_state(EnemyState.ATTACK)


func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.ATTACK_FINISHED:
			state_component.change_state(EnemyState.RECOVER)


func _on_cool_down_timer_timeout() -> void:
	state_component.change_state(EnemyState.CHASE)


func _on_state_component_state_changed(newState: Variant) -> void:
	match newState:
		EnemyState.ATTACK_PREPARE:
			prepare_timer.wait_time = attackPrepareTime
			prepare_timer.start()
		
		EnemyState.RECOVER:
			cool_down_timer.wait_time = attackCooldown
			cool_down_timer.start()
