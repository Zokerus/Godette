class_name EnvironmentState
extends Resource

@export_category("Sky")
@export var top_color: Color = Color(0.349, 0.588, 1.0)
@export var bottom_color: Color = Color(0.0, 0.329, 0.969)
@export var sun_scatter: Color = Color(0.298, 0.298, 0.298)

@export_category("Clouds")
@export_range(0.0, 1.0, 0.01) var cloud_density: float = 0.4
@export_range(0.01, 0.1, 0.001) var cloud_smoothness: float = 0.03
@export_range(0.1, 10.0, 0.1) var cloud_shadow_intensity: float = 1.0
@export var cloud_light_color: Color = Color.WHITE

@export_category("High Clouds")
@export_range(0.0, 1.0, 0.01) var high_cloud_density: float = 0.2

@export_category("Sun")
@export var sun_tint: Color = Color.WHITE
@export_range(0.0, 10.0, 0.1) var sun_scale: float = 3.0
@export_range(0.0, 10.0, 0.1) var sun_intensity: float = 3.0
@export_range(0.0, 1.0, 0.01) var sun_visibility: float = 1.0

@export_category("Moon")
@export var moon_tint: Color = Color.WHITE
@export_range(0.0, 10.0, 0.1) var moon_scale: float = 6.0
@export_range(0.0, 10.0, 0.1) var moon_intensity: float = 1.3
@export_range(0.0, 1.0, 0.01) var moon_visibility: float = 0.0

@export_category("Stars")
@export_range(0.0, 10.0, 0.1) var stars_intensity: float = 0.0
@export_range(0.0, 10.0, 0.1) var shooting_stars_intensity: float = 0.0
@export var shooting_star_tint: Color = Color.WHITE

@export_category("Lighting")
@export_range(0.0, 16.0, 0.01) var directional_light_energy: float = 1.0
@export_range(0.0, 16.0, 0.01) var ambient_light_energy: float = 1.0
@export_range(0.0, 1.0, 0.01) var ambient_sky_contribution: float = 1.0

@export_category("Fog")
@export_range(0.0, 1.0, 0.0001) var fog_density: float = 0.0
@export var fog_light_color: Color = Color.WHITE
@export_range(0.0, 16.0, 0.01) var fog_light_energy: float = 1.0

@export_category("Adjustment")
@export_range(0.0, 4.0, 0.01) var adjustment_brightness: float = 1.0
@export_range(0.0, 4.0, 0.01) var adjustment_contrast: float = 1.0
@export_range(0.0, 4.0, 0.01) var adjustment_saturation: float = 1.0
