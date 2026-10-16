shader_type canvas_item;

uniform vec4 outline_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_thickness = 0.03;
uniform float blur = 0.015;
uniform float glow = 0.02;
uniform vec2 texture_size = vec2(64.0, 64.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 pixel = vec2(1.0) / texture_size;
	float thickness = outline_thickness * 60.0;
	float glow_radius = thickness + glow * 60.0;
	float center = tex.a;

	// Sharp edge detection around the icon
	float max_n = max(
		max(texture(TEXTURE, UV + vec2(pixel.x * thickness, 0.0)).a,
		    texture(TEXTURE, UV - vec2(pixel.x * thickness, 0.0)).a),
		max(texture(TEXTURE, UV + vec2(0.0, pixel.y * thickness)).a,
		    texture(TEXTURE, UV - vec2(0.0, pixel.y * thickness)).a)
	);

	// Wider radius for the soft outer glow
	float max_g = max(
		max(texture(TEXTURE, UV + vec2(pixel.x * glow_radius, 0.0)).a,
		    texture(TEXTURE, UV - vec2(pixel.x * glow_radius, 0.0)).a),
		max(texture(TEXTURE, UV + vec2(0.0, pixel.y * glow_radius)).a,
		    texture(TEXTURE, UV - vec2(0.0, pixel.y * glow_radius)).a)
	);

	float edge = clamp(max_n - center, 0.0, 1.0);
	float soft_edge = smoothstep(0.1, 0.1 + blur, edge);

	float outer = clamp(max_g - center, 0.0, 1.0);
	float soft_glow = smoothstep(0.1, 0.1 + glow, outer);

	float combined = max(soft_edge, soft_glow * 0.6);

	if (center > 0.5) {
		COLOR = outline_color * center;
	} else if (combined > 0.01) {
		COLOR = outline_color * combined;
	} else {
		discard;
	}
}
