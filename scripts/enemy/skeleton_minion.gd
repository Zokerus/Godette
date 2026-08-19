class_name SkeletonMinion
extends Enemy

@onready var melee_component: MeleeComponent = $MeleeComponent


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if !is_dead:
		_alive_physics_process(delta)
	move_and_slide()

## Processes vision, combat visuals, and state behavior while the enemy is alive.
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
		
		EnemyState.BACK_TO_ORIGIN:
			handle_walk_back(delta)


func _on_prepare_timer_timeout() -> void:
	combat_component.attack(melee_component.get_random_attack())
	state_component.change_state(EnemyState.CHASE)
