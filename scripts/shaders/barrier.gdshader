shader_type spatial;

// Fade / distance uniforms
uniform float detection_distance : hint_range(0.0, 50.0) = 10.0;
uniform float fade_distance : hint_range(0.0, 20.0) = 5.0;
uniform vec3 player_position;

// Texture + triplanar controls
uniform sampler2D barrier_texture : source_color;
uniform float texture_scale : hint_range(0.1, 10.0) = 1.0;
uniform float triplanar_sharpness : hint_range(0.1, 10.0) = 2.0;
uniform bool flip_x = false;
uniform bool flip_y = true;
uniform bool flip_z = false;

// Alpha controls
uniform float min_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float max_alpha : hint_range(0.0, 1.0) = 0.8;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// Triplanar texture sampling
vec4 triplanar_texture(sampler2D tex, vec3 pos, vec3 normal, float scale, float sharpness) {
	// Normal-based blending
	vec3 blending = pow(abs(normal), vec3(sharpness));
	blending /= (blending.x + blending.y + blending.z);

	// World position projections
	vec2 x_proj = pos.yz * scale * vec2(1.0, flip_x ? -1.0 : 1.0);
	vec2 y_proj = pos.xz * scale * vec2(1.0, flip_y ? -1.0 : 1.0);
	vec2 z_proj = pos.xy * scale * vec2(1.0, flip_z ? -1.0 : 1.0);

	// Sample textures
	vec4 x_tex = texture(tex, x_proj);
	vec4 y_tex = texture(tex, y_proj);
	vec4 z_tex = texture(tex, z_proj);

	// Blend by normal weights
	return x_tex * blending.x + y_tex * blending.y + z_tex * blending.z;
}

void fragment() {
	// Distance to player
	float distance_to_player = length(world_position - player_position);

	// Fade factor (1 near, 0 far)
	float proximity = 1.0 - smoothstep(detection_distance - fade_distance, detection_distance, distance_to_player);

	// Triplanar sampled texture
	vec4 tex_color = triplanar_texture(barrier_texture, world_position, world_normal, texture_scale, triplanar_sharpness);

	// Apply fade to alpha
	float final_alpha = tex_color.a * mix(min_alpha, max_alpha, proximity);

	ALBEDO = tex_color.rgb;
	ALPHA = final_alpha;

	// Optional glow
	EMISSION = tex_color.rgb * proximity * 0.3;
}
