shader_type spatial;
render_mode blend_mix, diffuse_burley, specular_schlick_ggx, unshaded, cull_disabled;

uniform vec4 albedo : source_color = vec4(1.0, 0.5, 0.3, 1.0);
uniform float animation_speed : hint_range(0.0, 5.0) = 0.2;

const float nudge = 0.739513;
const float normalizer = 1.0 / sqrt(1.0 + nudge * nudge);

varying vec3 global_pos;

float SpiralNoiseC(vec3 p) {
    float n = 0.0;
    float iter = 1.0;
    for (int i = 0; i < 8; i++) {
        n += -abs(sin(p.y * iter) + cos(p.x * iter)) / iter;
        p.xy += vec2(p.y, -p.x) * nudge;
        p.xy *= normalizer;
        p.xz += vec2(p.z, -p.x) * nudge;
        p.xz *= normalizer;
        iter *= 1.733733;
    }
    return n;
}

float NebulaNoise(vec3 p) {
    float final = p.y + 4.5;
    final -= SpiralNoiseC(p.xyz);                                // mid-range noise
    final += SpiralNoiseC(p.zxy * 0.5123 + 100.0) * 4.0;         // large scale
    return final;
}

float myMap(vec3 p) {
    // Apply animation offset
    float time_offset = TIME * animation_speed;
    p += vec3(time_offset * 0.1, time_offset * 0.07, time_offset * 0.05);
    
    float NebNoise = abs(NebulaNoise(p / 0.5) * 0.5) + 0.03;
    return NebNoise;
}

void vertex() {
    global_pos = NODE_POSITION_WORLD;
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 ray_dir = normalize(world_pos - CAMERA_POSITION_WORLD);

    vec4 sum = vec4(0.0);
    float d = 1.0, t = 0.0;
    float ld = 0.0, td = 0.0, w = 0.0;
    float min_dist = 0.0, max_dist = 100.0;

    ALPHA = 0.0;
    t = min_dist * step(t, min_dist);

    for (int i = 0; i < 30; i++) {
        vec3 pos = world_pos + t * ray_dir;

        if (td > 0.9 || d < 0.1 * t || t > 10.0 || sum.a > 0.99 || t > max_dist) break;

        d = myMap(pos);
        d = max(d, 0.08);

        // Center glow
        vec3 ldst = global_pos - pos;
        float lDist = max(length(ldst), 0.001);
        sum.rgb += (albedo.rgb / (lDist * lDist) / 30.0);

        td += 1.0 / 70.0;
        d = max(d, 0.04);
        t += max(d * 0.1 * max(min(length(ldst), length(world_pos)), 1.0), 0.02);
    }

    ALBEDO = sum.rgb * t;
    ALPHA = ALBEDO.r;
}