extends CharacterBody3D
class_name PlayerController

const JUMP_VELOCITY = 4.5

#Stores the x/y direction the player is trying to look in
var mouseLookDelta := Vector2.ZERO
var isJumpPreparing: bool = false
var ignoreGroundAnimationUntilAirborne: bool = false
var defend: bool = false
var movementSpeedRatio : float
var weaponSelection: bool = true
var movementSpeedModifier: float = 1.0

@export var mouseSensitivity: float = 0.002
@export var padLookSensitivity: float = 2.0
@export var min_vertical_boundary: float = -60.0
@export var max_vertical_boundary: float = 17.0
@export var moveSpeed: float = 4.0
@export var runSpeed: float = 6.0
@export var blockMoveSpeed: float = 2.0
@export_category("Character Context")
@export var character: CharacterContext

@onready var combatComponent: CombatComponent = $CombatComponent
@onready var meleeComponent: MeleeComponent = $MeleeComponent
@onready var rig_yaw_pivot: Node3D = $RigYawPivot
@onready var camera_yaw_pivot: Node3D = $CameraYawPivot
@onready var camera_pitch_pivot: Node3D = $CameraYawPivot/CameraPitchPivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
			mouseLookDelta += event.relative
	
	if Input.is_action_just_pressed("ui_pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	handle_camera_rotation(delta)
	var direction := get_movement_direction()
	handle_movement(direction, delta)
	handle_jump(delta)
	handle_fall(delta)
	ability_logic(delta)

	move_and_slide()

func handle_camera_rotation(delta: float) -> void:
	 # Gamepad look
	var padLook := Vector2(
		Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
		Input.get_action_strength("look_down") - Input.get_action_strength("look_up"))
	
	var look := Vector2.ZERO
	look -= mouseLookDelta * mouseSensitivity
	look -= padLook * padLookSensitivity * delta
	
	camera_yaw_pivot.rotate_y(look.x)
	camera_pitch_pivot.rotate_x(look.y)
	camera_pitch_pivot.rotation.x = clampf(camera_pitch_pivot.rotation.x, deg_to_rad(min_vertical_boundary), deg_to_rad(max_vertical_boundary))
	
	#$SpringArm.global_transform = vertical_pivot.global_transform
	mouseLookDelta = Vector2.ZERO

func get_movement_direction()-> Vector3:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var yaw_basis := camera_yaw_pivot.global_transform.basis
	var forward := yaw_basis.z
	forward.y = 0
	forward = forward.normalized()

	var right := yaw_basis.x
	right.y = 0
	right = right.normalized()
	
	var direction := (forward * input_dir.y + right * input_dir.x).normalized()
	return direction

func handle_movement(direction: Vector3, delta: float) -> void:
	var is_running: bool = Input.is_action_pressed("run")
	var speed : float = blockMoveSpeed if combatComponent.isDefending else (runSpeed if is_running else moveSpeed )
	
	if isJumpPreparing or !is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
		#velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
		return
	
	if is_on_floor() and !ignoreGroundAnimationUntilAirborne:
		if direction != Vector3.ZERO:
			
			look_toward_direction(direction, delta)
			velocity.x = direction.x * speed * movementSpeedModifier
			velocity.z = direction.z * speed * movementSpeedModifier
			character.rig.travel("Running_A")
		else:
			velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
			velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
			character.rig.travel("Idle_A")
			
		movementSpeedRatio = clampf(Vector3(velocity.x, 0, velocity.z).length() / speed, 0.0, 1.0)
		
func look_toward_direction(direction: Vector3, delta: float)-> void:
	var target_transform:= rig_yaw_pivot.global_transform.looking_at(rig_yaw_pivot.global_position - direction, Vector3.UP, true)
	
	rig_yaw_pivot.global_transform = rig_yaw_pivot.global_transform.interpolate_with(target_transform,  1.0 - exp(-10 * delta))

func handle_jump(_delta: float) -> void:
	var tempVelocity: Vector3 = velocity
	tempVelocity.y = 0
	if Input.is_action_just_pressed("jump") && is_on_floor():
		isJumpPreparing = true
		if tempVelocity == Vector3.ZERO:
			character.rig.travel("Jump")
		else:
			_on_jump_takeoff_requested()

func _on_jump_takeoff_requested() -> void:
	if isJumpPreparing == false:
		return
	velocity.y = JUMP_VELOCITY
	ignoreGroundAnimationUntilAirborne = true
	isJumpPreparing = false

func handle_fall(delta: float) -> void:
	var tempVelocity: Vector3 = velocity
	tempVelocity.y = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		ignoreGroundAnimationUntilAirborne = false
		if velocity.y <= 0 or tempVelocity != Vector3.ZERO:
			character.rig.travel("Fall")

func ability_logic(delta: float) -> void:
	#actual attack
	if Input.is_action_just_pressed("attack"):
		combatComponent.attack(&"Chop")
	
	#defend
	if Input.is_action_pressed("block"):
		combatComponent.startDefend()
		defend = combatComponent.isDefending
		character.rig.defend(delta, combatComponent.isDefending, movementSpeedRatio)
	else:
		combatComponent.stopDefend()
		character.rig.defend(delta, false, 1.0)
		defend = false
	
	#switch weapon
	if Input.is_action_just_pressed("weapon_switch"):
		weaponSelection = !weaponSelection
		character.rig.switchWeapons(weaponSelection)
		if weaponSelection:
			combatComponent.activeCombatMode = CombatComponent.CombatMode.MELEE
		else:
			combatComponent.activeCombatMode = CombatComponent.CombatMode.MAGIC
	
	#if Input.is_action_just_pressed("ui_accept"):
		#combatComponent.getHit(&"LightHit")
		#changeSpeedModifier(0.0, 0.3, 0.8)

func _onAnimationEventReceived(event: int) -> void:
	match event:
		AnimationEventRelay.AnimationEvents.JUMP_TAKEOFF:
			_on_jump_takeoff_requested()

func changeSpeedModifier(value: float, start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "movementSpeedModifier", value, start_duration)
	tween.tween_property(self, "movementSpeedModifier", 1.0, end_duration)
