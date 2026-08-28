shader_type spatial;

uniform sampler2D terrain_mask;
uniform sampler2D gras_texture;
uniform sampler2D dirt_texture;
uniform sampler2D rock_texture;

uniform float min_rock_slope: hint_range(0.0, 1.0) = 0.5;
uniform float max_grass_slope: hint_range(0.0, 1.0) = 0.9;


varying float normal_y;

void vertex() {
	// Called for every vertex the material is visible on.
	normal_y = NORMAL.y;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 terrain_albedo = texture(terrain_mask, UV).rgb;
	
	vec3 grass_albedo = texture(gras_texture, UV).rgb;
	vec3 dirt_albedo = texture(dirt_texture, UV).rgb;
	vec3 rock_albedo = texture(rock_texture, UV).rgb;
	
	// Manual terrain painting
	vec3 color = mix(grass_albedo, dirt_albedo, terrain_albedo.r);
	color = mix(color, rock_albedo, terrain_albedo.g);
	
	// Automatic rock placement based on slope
	float grass_weight = smoothstep(min_rock_slope, max_grass_slope, normal_y);
	
	ALBEDO = mix(rock_albedo, color, grass_weight);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
