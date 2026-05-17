class_name SkeletonMinion
extends Enemy

@onready var melee_component: MeleeComponent = $MeleeComponent


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



func _on_vision_component_target_identified(object: Node3D) -> void:
	target = object
	state_component.change_state(EnemyState.CHASE)


func _on_vision_component_target_lost() -> void:
	lastKnownPosition = target.global_position
	target = null
	state_component.change_state(EnemyState.SEARCH)
	#TODO: Later search play at last known position --> run back to origin


func _on_prepare_timer_timeout() -> void:
	combat_component.attack(melee_component.get_random_attack())
	state_component.change_state(EnemyState.CHASE)


func _on_animation_event_relay_component_animation_event_received(event: AnimationEventRelay.AnimationEvents) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.ATTACK_FINISHED:
			state_component.change_state(EnemyState.CHASE)


func _on_state_component_state_changed(newState: Variant) -> void:
	match newState:
		EnemyState.ATTACK_PREPARE:
			prepare_timer.wait_time = attackPrepareTime
			prepare_timer.start()
