class_name EnvironmentController
extends Node

@export_category("Dependencies")
@export var world_time: WorldTimeManager
@export var world_environment: WorldEnvironment
@export var sun_orbit: Node3D
@export var sun: DirectionalLight3D

@export_category("Sun")
@export var noon_sun_rotation := Vector3(-64.3, 15.0, 0.0)

@export_category("states")
@export var day_state: EnvironmentState
@export var night_state: EnvironmentState

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
	
	var day_factor := _get_day_factor(time_of_day)
	
	_update_sun_rotation(world_time.get_normalized_time())
	_update_sky(day_factor)
	_update_lighting(day_factor)
	_update_environment_settings(day_factor)
	
	#_update_celestial_visibility(day_factor, night_factor)
	#_update_sky_colors(day_factor)
	#_update_stars(night_factor)


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
	

## Updates all time-dependent sky shader parameters.
func _update_sky(day_factor: float) -> void:
	sky_material.set_shader_parameter("top_color", night_state.top_color.lerp(day_state.top_color, day_factor))
	sky_material.set_shader_parameter("bottom_color", night_state.bottom_color.lerp(day_state.bottom_color, day_factor))
	sky_material.set_shader_parameter("sun_scatter", night_state.sun_scatter.lerp(day_state.sun_scatter, day_factor))
	sky_material.set_shader_parameter("clouds_density", lerp(night_state.cloud_density, day_state.cloud_density, day_factor))
	sky_material.set_shader_parameter("clouds_smoothness", lerp(night_state.cloud_smoothness, day_state.cloud_smoothness, day_factor))
	sky_material.set_shader_parameter("clouds_shadow_intensity", lerp(night_state.cloud_shadow_intensity, day_state.cloud_shadow_intensity, day_factor))
	sky_material.set_shader_parameter("clouds_light_color", night_state.cloud_light_color.lerp(day_state.cloud_light_color, day_factor))
	sky_material.set_shader_parameter("high_clouds_density", lerp(night_state.high_cloud_density, day_state.high_cloud_density, day_factor))

	_update_celestial_objects(day_factor)
	_update_stars(day_factor)


## Updates sun and moon shader properties.
func _update_celestial_objects(day_factor: float) -> void:
	sky_material.set_shader_parameter("sun_tint", night_state.sun_tint.lerp(day_state.sun_tint, day_factor))
	sky_material.set_shader_parameter("sun_scale", lerp(night_state.sun_scale, day_state.sun_scale, day_factor))
	sky_material.set_shader_parameter("sun_intensity", lerp(night_state.sun_intensity, day_state.sun_intensity, day_factor))
	sky_material.set_shader_parameter("sun_visibility", lerp(night_state.sun_visibility, day_state.sun_visibility, day_factor))
	sky_material.set_shader_parameter("moon_tint", night_state.moon_tint.lerp(day_state.moon_tint, day_factor))
	sky_material.set_shader_parameter("moon_scale", lerp(night_state.moon_scale, day_state.moon_scale, day_factor))
	sky_material.set_shader_parameter("moon_intensity", lerp(night_state.moon_intensity, day_state.moon_intensity, day_factor))
	sky_material.set_shader_parameter("moon_visibility", lerp(night_state.moon_visibility, day_state.moon_visibility, day_factor))


## Updates stars and shooting stars for the current day-night state.
func _update_stars(day_factor: float) -> void:
	sky_material.set_shader_parameter("stars_intensity", lerp(night_state.stars_intensity, day_state.stars_intensity, day_factor))
	sky_material.set_shader_parameter("shooting_stars_intensity", lerp(night_state.shooting_stars_intensity, day_state.shooting_stars_intensity, day_factor))
	sky_material.set_shader_parameter("shooting_star_tint", night_state.shooting_star_tint.lerp(day_state.shooting_star_tint, day_factor))


## Updates directional and ambient lighting.
func _update_lighting(day_factor: float) -> void:
	if sun != null:
		sun.light_energy = lerp(night_state.directional_light_energy, day_state.directional_light_energy, day_factor)

	environment.ambient_light_energy = lerp(night_state.ambient_light_energy, day_state.ambient_light_energy, day_factor)
	environment.ambient_light_sky_contribution = lerp(night_state.ambient_sky_contribution, day_state.ambient_sky_contribution, day_factor)


## Updates fog and post-processing properties.
func _update_environment_settings(day_factor: float) -> void:
	environment.fog_density = lerp(night_state.fog_density, day_state.fog_density, day_factor)
	environment.fog_light_color = night_state.fog_light_color.lerp(day_state.fog_light_color, day_factor)
	environment.fog_light_energy = lerp(night_state.fog_light_energy, day_state.fog_light_energy, day_factor)
	environment.adjustment_brightness = lerp(night_state.adjustment_brightness, day_state.adjustment_brightness, day_factor)
	environment.adjustment_contrast = lerp(night_state.adjustment_contrast, day_state.adjustment_contrast, day_factor)
	environment.adjustment_saturation = lerp(night_state.adjustment_saturation, day_state.adjustment_saturation, day_factor)
