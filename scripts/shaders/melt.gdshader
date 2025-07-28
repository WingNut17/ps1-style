shader_type canvas_item;

uniform sampler2D screen_texture;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int column_count : hint_range(50, 300) = 160;
uniform float random_seed = 0.0;

float random(float x) {
    return fract(sin((x + random_seed) * 12.9898) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Calculate which column this pixel belongs to
    float column_index = floor(uv.x * float(column_count));

    // Generate a random offset for this column based on its index
    float column_random = random(column_index);

    // Calculate melt offset for this column
    float melt_delay = column_random * 0.3; // Random delay per column
    float melt_speed = 0.8 + column_random * 0.4; // Vary fall speed

    // Calculate current melt progress for this specific column
    float column_progress = clamp((progress - melt_delay) * melt_speed, 0.0, 1.0);

    // Calculate how far this column has "fallen"
    float fall_distance = column_progress * 1.5; // 1.5 = falls off screen + some extra

    // Offset the UV coordinates
    vec2 melted_uv = uv;
    melted_uv.y -= fall_distance;

    // If the melted UV is still on screen, sample the texture
    if (melted_uv.y >= 0.0 && melted_uv.y <= 1.0) {
        COLOR = texture(screen_texture, melted_uv);
    } else {
        // This part has "melted away", make it transparent
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}