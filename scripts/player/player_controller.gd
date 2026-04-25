extends CharacterBody3D
class_name PlayerController

const JUMP_VELOCITY = 4.5

#Stores the x/y direction the player is trying to look in
var mouseLookDelta := Vector2.ZERO
var isJumpPreparing := false
var ignoreGroundAnimationUntilAirborne := false

@export var mouseSensitivity := 0.002
@export var padLookSensitivity := 2.0
@export var min_vertical_boundary: float = -60
@export var max_vertical_boundary: float = 17
@export var moveSpeed := 4.0
@export var runSpeed := 6.0

@onready var rig: PlayerRig = $RigYawPivot/Godette
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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var yaw_basis := camera_yaw_pivot.global_transform.basis
	var forward := yaw_basis.z
	forward.y = 0
	forward = forward.normalized()

	var right := yaw_basis.x
	right.y = 0
	right = right.normalized()
	
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	return direction

func handle_movement(direction: Vector3, delta: float) -> void:
	var is_running: bool = Input.is_action_pressed("run")
	
	if isJumpPreparing or !is_on_floor():
		velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
		return
	
	if is_on_floor() and !ignoreGroundAnimationUntilAirborne:
		if direction != Vector3.ZERO:
			var speed = runSpeed if is_running else moveSpeed
			look_toward_direction(direction, delta)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			rig.travel("Running_A")
		else:
			velocity.x = move_toward(velocity.x, 0, moveSpeed * 4.0 * delta)
			velocity.z = move_toward(velocity.z, 0, moveSpeed * 4.0 * delta)
			rig.travel("Idle_A")
		
func look_toward_direction(direction: Vector3, delta: float)-> void:
	var target_transform:= rig_yaw_pivot.global_transform.looking_at(rig_yaw_pivot.global_position - direction, Vector3.UP, true)
	
	rig_yaw_pivot.global_transform = rig_yaw_pivot.global_transform.interpolate_with(target_transform,  1.0 - exp(-10 * delta))

func handle_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") && is_on_floor():
		
		isJumpPreparing = true
		rig.travel("Jump")

func _on_jump_takeoff_requested() -> void:
	if isJumpPreparing == false:
		return
	velocity.y = JUMP_VELOCITY
	ignoreGroundAnimationUntilAirborne = true
	isJumpPreparing = false

func handle_fall(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		ignoreGroundAnimationUntilAirborne = false
		if velocity.y <= 0:
			rig.travel("Fall")
		
