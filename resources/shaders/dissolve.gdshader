shader_type canvas_item;

uniform vec3 base_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 inside_color : source_color = vec3(0.2, 0.2, 0.2);

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;

uniform vec3 glow_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float glow_intensity = 5.0;
uniform float glow_border_width : hint_range(0.0, 0.25) = 0.05;
uniform float glow_border_smoothness : hint_range(0.0, 0.1) = 0.04;

uniform sampler2D noise_texture : source_color;

void fragment() {
    // Sample textures
    vec4 tex = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;

    // Base dissolve math
    float border_mask = 0.0;
    if (dissolve_amount > 0.0) {
        float border_size = dissolve_amount + glow_border_width;

        border_mask = 1.0 - smoothstep(
            border_size - glow_border_smoothness,
            border_size + glow_border_smoothness,
            noise
        );
    }

    // Glow emission
    vec3 emission = glow_color * border_mask * glow_intensity;

    // Dissolve base surface color
    vec3 final_color = mix(tex.rgb * base_color, vec3(0.0), border_mask);

    // If back-facing (2D doesn’t have FRONT_FACING, so we ignore)
    // If you want inside color, you can mix based on dissolve
    if (noise < dissolve_amount) {
        final_color = inside_color;
    }

    COLOR = vec4(final_color, tex.a);

    // Alpha cutout (scissor equivalent)
    if (noise < dissolve_amount) {
        discard;
    }

    // Add emission by overwriting visible color
    COLOR.rgb += emission;
}
