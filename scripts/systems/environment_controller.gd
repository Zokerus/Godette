class_name EnvironmentController
extends Node

@export_category("Dependencies")
@export var world_time: WorldTimeManager
@export var world_environment: WorldEnvironment
@export var sun_orbit: Node3D
@export var sun: DirectionalLight3D

@export_category("Sun")
@export var noon_sun_rotation := Vector3(-64.3, 15.0, 0.0)

@export_category("Day Sky")
@export var day_top_color := Color(0.349, 0.588, 1.0)
@export var day_bottom_color := Color(0.0, 0.329, 0.969)
@export var day_sun_scatter := Color(0.298, 0.298, 0.298)

@export_category("Night Sky")
@export var night_top_color := Color(0.027, 0.102, 0.251)
@export var night_bottom_color := Color(0.027, 0.102, 0.251)
@export var night_sun_scatter := Color(0.125, 0.086, 0.373)
@export var night_stars_intensity: float = 5.0

var environment: Environment
var sky_material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_environment()
	
	if sun != null:
		sun.rotation_degrees = noon_sun_rotation
	
	if world_time != null:
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


## Updates the complete day-night environment for the given world time.
func update_environment(time_of_day: float) -> void:
	if sky_material == null:
		return
	
	_update_sun_rotation(world_time.get_normalized_time())
	
	var day_factor := _get_day_factor(time_of_day)
	var night_factor := 1.0 - day_factor
	
	_update_celestial_visibility(day_factor, night_factor)
	_update_sky_colors(day_factor)
	_update_stars(night_factor)


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

## Calculates daylight intensity from the current world time.
func _get_day_factor(time_of_day: float) -> float:
	var angle := ((time_of_day - 6.0) / 24.0) * TAU
	return clamp(sin(angle) * 0.5 + 0.5, 0.0, 1.0)
	

## Updates sun and moon visibility.
func _update_celestial_visibility(day_factor: float, night_factor: float) -> void:
	sky_material.set_shader_parameter("sun_visibility", day_factor)
	sky_material.set_shader_parameter("moon_visibility", night_factor)
	
	
	## Updates sky colors between day and night presets.
func _update_sky_colors(day_factor: float) -> void:
	var top_color := night_top_color.lerp(day_top_color, day_factor)
	var bottom_color := night_bottom_color.lerp(day_bottom_color, day_factor)
	var sun_scatter := night_sun_scatter.lerp(day_sun_scatter, day_factor)

	sky_material.set_shader_parameter("top_color", top_color)
	sky_material.set_shader_parameter("bottom_color", bottom_color)
	sky_material.set_shader_parameter("sun_scatter", sun_scatter)
	
	
	## Updates star visibility for the current night intensity.
func _update_stars(night_factor: float) -> void:
	sky_material.set_shader_parameter("stars_intensity", night_stars_intensity * night_factor)
