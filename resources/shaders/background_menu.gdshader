shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.10, 0.10, 0.12, 1.0);
uniform vec4 smoke_color : source_color = vec4(0.22, 0.22, 0.28, 1.0);

uniform float speed = 0.08;
uniform float noise_scale = 2.5;
uniform float contrast = 2.0;
uniform float softness = 0.3;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) +
	       (c - a) * u.y * (1.0 - u.x) +
	       (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amplitude * noise(p);
		p *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV;

	// Vertical rising motion
	uv.y -= TIME * speed;

	// Slight horizontal drift
	uv.x += sin(TIME * 0.2) * 0.05;

	vec2 p = uv * noise_scale;

	float n = fbm(p);

	// Shape smoke: softer bottom, lighter top
	n = pow(n, contrast);

	float mask = smoothstep(
		0.4 - softness,
		0.6 + softness,
		n
	);

	COLOR = mix(base_color, smoke_color, mask);
}
