class_name SkeletonMage
extends Enemy


@onready var magic_component: MagicComponent = $MagicComponent


func _physics_process(delta: float) -> void:
	vision_component.updateVision()
	combat_component.updateCombatVisuals(delta, movementSpeedRatio)
	
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


func _on_prepare_timer_timeout() -> void:
	combat_component.attack(&"")
	state_component.change_state(EnemyState.CHASE)
