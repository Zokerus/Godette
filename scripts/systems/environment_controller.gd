class_name EnvironmentController
extends Node

@export_category("Dependencies")
@export var world_time: WorldTimeManager
@export var world_environment: WorldEnvironment
@export var sun_orbit: Node3D
@export var sun: DirectionalLight3D

@export_category("Sun")
@export var noon_sun_rotation := Vector3(-64.3, 15.0, 0.0)

var environment: Environment
var sky_material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_environment()
	#sun.rotation_degrees = noon_sun_rotation
	
	if world_time:
		world_time.time_changed.connect(_on_time_changed)
		update_environment(world_time.get_time())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## Initializes unique runtime environment resources and caches the sky material.
func _initialize_environment() -> void:
	if world_environment == null:
		push_error("EnvironmentController: WorldEnvironment is not assigned.")
		return

	if world_environment.environment == null:
		push_error("EnvironmentController: Environment resource is missing.")
		return

	environment = world_environment.environment.duplicate(true)
	world_environment.environment = environment

	if environment.sky == null:
		push_error("EnvironmentController: Sky resource is missing.")
		return

	environment.sky = environment.sky.duplicate(true)

	if environment.sky.sky_material == null:
		push_error("EnvironmentController: Sky material is missing.")
		return

	if environment.sky.sky_material is not ShaderMaterial:
		push_error("EnvironmentController: Sky material is not a ShaderMaterial.")
		return

	sky_material = environment.sky.sky_material.duplicate() as ShaderMaterial
	environment.sky.sky_material = sky_material


## Updates all environment properties based on the current world time.
func update_environment(time_of_day: float) -> void:
	var normalized_time := time_of_day / 24.0

	_update_sun_rotation(normalized_time)


## Updates the sun orbit based on normalized world time.
func _update_sun_rotation(normalized_time: float) -> void:
	if sun_orbit == null:
		return

	var time_of_day := normalized_time * 24.0
	var orbit_angle := (time_of_day - 12.0) * 15.0

	sun_orbit.rotation_degrees.z = orbit_angle


## Handles changes to the current world time.
func _on_time_changed(time_of_day: float) -> void:
	update_environment(time_of_day)
