class_name SkeletonMinion
extends Enemy

@onready var melee_component: MeleeComponent = $MeleeComponent


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if !is_dead:
		_alive_physics_process(delta)
	move_and_slide()


func _apply_gravity(delta: float)-> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0


func _alive_physics_process(delta: float)-> void:
	vision_component.updateVision()
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
	combat_component.attack(melee_component.get_random_attack())
	state_component.change_state(EnemyState.CHASE)

## Signal from HealthComponent if enemy dies
func _on_health_component_died() -> void:
	print("Minion died!")
	die()
