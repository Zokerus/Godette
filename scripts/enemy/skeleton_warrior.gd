class_name SkeletonWarrior
extends Enemy

@export var blockChancePerSecond: float = 0.35
@export var blockRangeMultiplier: float = 4

@onready var melee_component: MeleeComponent = $MeleeComponent


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if state_component.currentState != EnemyState.DEAD:
		_alive_physics_process(delta)
	move_and_slide()
	

func handle_chase(delta: float) -> void:
	#If target is lost or gone, go back to IDLE state
	#TODO: Enemy should go back to origin or back to daily routine
	if target == null:
		state_component.change_state(EnemyState.IDLE)
		return
	
	#special Attack
	
	var distance := global_position.distance_to(target.global_position)
	
	#Within attack range -> take decision
	if distance <= attackRange:
		stop_movement(delta)
		
		# 1. Check block independently from attack cooldown
		if handle_block_logic(delta, distance):
			return
		
		# 2. Check attack
		if combat_component.can_attack():
			state_component.change_state(EnemyState.ATTACK_PREPARE)
		return 
	
	#Outside attack range
	#check block while chasing player
	handle_block_logic(delta, distance)
	
	#3. Movement
	update_navigation(target.global_position)
	handle_movement(delta)


func handle_block_logic(delta: float, distance: float) -> bool:
	if combat_component.isDefending:
		return true
	
	if !combat_component.can_block() or target == null:
		return false
	
	#start blocking, if within in certain distance
	if distance > attackRange * blockRangeMultiplier:
		return false
	
	if randf() < blockChancePerSecond * delta:
		return combat_component.startDefend(false)
	return false


func _on_prepare_timer_timeout() -> void:
	combat_component.attack(melee_component.get_random_attack())
	state_component.change_state(EnemyState.CHASE)
