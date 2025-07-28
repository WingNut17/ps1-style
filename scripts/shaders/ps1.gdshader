shader_type spatial;

render_mode blend_mix,
	depth_draw_opaque,
	cull_back,
	diffuse_burley,
	specular_schlick_ggx,
	depth_prepass_alpha,
	shadows_disabled,
	skip_vertex_transform;

varying float w_comp;
varying vec3 world_pos;

uniform float point_size : hint_range(0, 128);
uniform float roughness : hint_range(0, 1);
uniform float specular;
uniform float metallic;

uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo : source_color = vec4(1, 1, 1, 1);

uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset = vec3(0, 0, 0);

uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;

uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy;

uniform bool use_triplanar = false;
uniform float triplanar_scale = 1.0; // Uniform world scale
uniform float triplanar_blend_sharpness = 4.0; // Higher = harder blend

uniform ivec2 resolution = ivec2(320, 240);
uniform bool affine_mapping = true;
uniform float alpha_scissor : hint_range(0, 1) = 0.5;
uniform float jitter : hint_range(0, 1) = 0.25;

void vertex()
{
	vec3 local_pos = VERTEX;
	world_pos = (MODEL_MATRIX * vec4(local_pos, 1.0)).xyz;

	VERTEX = (MODELVIEW_MATRIX * vec4(local_pos, 1.0)).xyz;
	w_comp = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX /= w_comp;

	vec2 grid_to_snap = vec2(resolution) * (1.0 - jitter);
	VERTEX.x = floor(VERTEX.x * grid_to_snap.x) / grid_to_snap.x;
	VERTEX.y = floor(VERTEX.y * grid_to_snap.y) / grid_to_snap.y;
	VERTEX *= w_comp;

	if (affine_mapping == true) {
		UV *= w_comp;
	}

	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

vec4 world_triplanar_texture(sampler2D tex, vec3 world_position, vec3 normal)
{
	vec3 abs_n = abs(normal);
	vec3 blend = pow(abs_n, vec3(triplanar_blend_sharpness));
	blend /= (blend.x + blend.y + blend.z); // Normalize weights

	// World-scale UVs
	vec2 uv_x = world_position.yz * triplanar_scale;
	vec2 uv_y = world_position.xz * triplanar_scale;
	vec2 uv_z = world_position.xy * triplanar_scale;

	vec4 x = texture(tex, uv_x);
	vec4 y = texture(tex, uv_y);
	vec4 z = texture(tex, uv_z);

	return x * blend.x + y * blend.y + z * blend.z;
}

void fragment()
{
	vec2 base_uv = UV;
	if (affine_mapping == true) {
		base_uv /= w_comp;
	}

	vec4 color_base = COLOR;
	vec4 texture_color;

	if (use_triplanar) {
		texture_color = world_triplanar_texture(texture_albedo, world_pos, NORMAL);
	} else {
		vec2 scaled_uv = base_uv * uv1_scale.xy + uv1_offset.xy;
		texture_color = texture(texture_albedo, scaled_uv);
	}

	ALBEDO = albedo.rgb * texture_color.rgb;
	ALPHA = texture_color.a * color_base.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	SPECULAR = specular;

	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	EMISSION = (emission.rgb + emission_tex) * emission_energy;
}
