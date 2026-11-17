shader_type canvas_item;
// Atmospheric backdrop: nebula mist, drifting embers, optional sigil ring, vignette.

uniform vec4 base_col : source_color = vec4(0.043, 0.035, 0.070, 1.0);
uniform vec4 glow_a : source_color = vec4(0.56, 0.38, 0.90, 1.0);   // arcane mist
uniform vec4 glow_b : source_color = vec4(0.91, 0.43, 0.20, 1.0);   // ember floor
uniform vec4 glow_c : source_color = vec4(0.30, 0.80, 0.76, 1.0);   // teal wisps
uniform vec4 mote_col : source_color = vec4(1.0, 0.80, 0.45, 1.0);
uniform float rune = 0.0;
uniform vec2 rune_center = vec2(0.5, 0.3);
uniform float speed = 1.0;
uniform float mist_amount = 1.0;
uniform float mote_amount = 1.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

float motes(vec2 p, float t, float scale, float density) {
	vec2 g = p * scale + vec2(0.0, t * 0.35);
	vec2 id = floor(g);
	vec2 f = fract(g) - 0.5;
	float h = hash(id);
	if (h < density) return 0.0;
	vec2 off = (vec2(hash(id + 3.1), hash(id + 7.7)) - 0.5) * 0.7;
	off.x += sin(t * 0.8 + h * 30.0) * 0.12;
	float d = length(f - off);
	float tw = 0.55 + 0.45 * sin(t * (1.5 + h * 3.0) + h * 40.0);
	return smoothstep(0.07, 0.0, d) * tw;
}

void fragment() {
	float t = TIME * speed;
	vec2 uv = UV;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = vec2((uv.x - 0.5) * aspect, uv.y - 0.5);

	vec3 col = base_col.rgb;

	// Layered mist with domain warping
	float n1 = fbm(p * 1.8 + vec2(t * 0.015, -t * 0.010));
	float n2 = fbm(p * 3.2 + n1 * 1.6 - vec2(t * 0.020, 0.0));
	float mist = smoothstep(0.42, 0.95, n2);
	col += glow_a.rgb * mist * 0.22 * mist_amount * (1.15 - uv.y * 0.6);
	float wisp = smoothstep(0.55, 0.9, fbm(p * 2.4 - n2 + vec2(0.0, t * 0.012)));
	col += glow_c.rgb * wisp * 0.07 * (1.0 - uv.x * 0.7);

	// Ember glow rising from the bottom edge
	float floor_glow = pow(uv.y, 3.2) * (0.6 + 0.4 * n1);
	col += glow_b.rgb * floor_glow * 0.26;

	// Drifting embers (two depths)
	float m = motes(p, t, 9.0, 0.82) * 0.9 + motes(p + 4.0, t * 0.6, 17.0, 0.86) * 0.45;
	col += mote_col.rgb * m * mote_amount * (0.35 + 0.65 * uv.y);

	// Sigil ring
	if (rune > 0.0) {
		vec2 rc = vec2((rune_center.x - 0.5) * aspect, rune_center.y - 0.5);
		vec2 q = p - rc;
		float r = length(q);
		float ang = atan(q.y, q.x);
		float px = SCREEN_PIXEL_SIZE.y * 1.4;
		float ring = 0.0;
		ring += smoothstep(px, 0.0, abs(r - 0.34));
		ring += smoothstep(px, 0.0, abs(r - 0.31)) * 0.6;
		ring += smoothstep(px, 0.0, abs(r - 0.22)) * 0.35;
		// rotating tick marks between the outer rings
		float ticks = step(0.92, fract((ang + t * 0.03) * 36.0 / 6.2832));
		ring += ticks * step(0.312, r) * step(r, 0.338) * 0.5;
		// counter-rotating hexagram spokes on the inner ring
		float sp = abs(sin((ang - t * 0.05) * 3.0));
		ring += smoothstep(0.03, 0.0, sp) * step(0.05, r) * step(r, 0.22) * 0.25;
		float pulse = 0.75 + 0.25 * sin(t * 0.7);
		col += mix(glow_b.rgb, mote_col.rgb, 0.5) * ring * 0.16 * rune * pulse;
		col += glow_a.rgb * smoothstep(0.36, 0.0, r) * 0.05 * rune;
	}

	// Vignette + grain
	float v = length((uv - 0.5) * vec2(1.0, 1.15));
	col *= 1.0 - 0.72 * pow(v, 2.4);
	col += (hash(uv * 913.0 + fract(t)) - 0.5) * 0.018;

	COLOR = vec4(col, 1.0);
}
