class_name Enemy
extends CharacterBody3D

enum EnemyState {
	IDLE,
	CHASE,
	ATTACK_PREPARE,
	ATTACK,
	SEARCH,
}

@export var moveSpeed: float = 2.0
@export var attackRange: float = 1.8
@export var attackCooldown: float = 1.2
@export var attackPrepareTime: float = 0.3
@export var attackPrepareMoveRangeMultiplier: float = 1.5
@export var attackPrepareCancelRangeMultiplier: float = 3.0

var pointOfOrigin:= Vector3.ZERO
var target: Node3D
var lastKnownPosition: Vector3
var movementSpeedRatio: float

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var state_component: StateComponent = $StateComponent
@onready var vision_component: VisionComponent = $VisionComponent
@onready var rig_yaw_pivot: Node3D = $RigYawPivot
@onready var character: CharacterContext = $CharacterContext
@onready var prepare_timer: Timer = $Timers/PrepareTimer
@onready var combat_component: CombatComponent = $CombatComponent


func _ready() -> void:
	pointOfOrigin = global_position


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
	
	movementSpeedRatio = clampf(Vector3(velocity.x, 0, velocity.z).length() / speed, 0.0, 1.0)
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
	
	#enemy is still attacking and must not move
	if combat_component.isPerformingAction:
		stop_movement(delta)
		return
	
	#special Attack
	
	var distance := global_position.distance_to(target.global_position)
	
	if distance <= attackRange:
		stop_movement(delta)
		if combat_component.can_attack():
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


func handle_special_combat(delta: float) -> void:
	pass
