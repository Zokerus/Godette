class_name SkeletonMage
extends Enemy


@onready var magic_component: MagicComponent = $MagicComponent


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if state_component.currentState != EnemyState.DEAD:
		_alive_physics_process(delta)
	move_and_slide()



func _on_prepare_timer_timeout() -> void:
	combat_component.attack(&"")
	state_component.change_state(EnemyState.CHASE)
