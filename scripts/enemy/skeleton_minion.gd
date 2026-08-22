class_name SkeletonMinion
extends Enemy

@onready var melee_component: MeleeComponent = $MeleeComponent


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if state_component.currentState != EnemyState.DEAD:
		_alive_physics_process(delta)
	move_and_slide()


func _on_prepare_timer_timeout() -> void:
	combat_component.attack(melee_component.get_random_attack())
	state_component.change_state(EnemyState.CHASE)
