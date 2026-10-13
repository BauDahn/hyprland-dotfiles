#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
layout(location = 0) out vec4 fragColor;

// Muestreo exacto por píxel: sin interpolación, así no aparecen franjas borrosas de color en los bordes.
ivec2 SZ;
vec3 at(ivec2 p) { return texelFetch(tex, clamp(p, ivec2(0), SZ - 1), 0).rgb; }
float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }
float sat(vec3 c) { return (max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b))) / max(max(c.r, max(c.g, c.b)), 0.001); }
// Aberración cromática en píxeles ENTEROS (radial, crece hacia las esquinas)
ivec2 aberr(vec2 c, float k) { return ivec2(floor(c * dot(c, c) * k * vec2(SZ) + 0.5)); }
vec3 split(ivec2 p, ivec2 o) { return vec3(at(p + o).r, at(p).g, at(p - o).b); }

// Retrowave: scanlines, más saturación y un leve glow magenta en los bordes.
void main() {
    SZ = textureSize(tex, 0);
    vec2 uv = v_texcoord;
    ivec2 p = ivec2(floor(uv * vec2(SZ)));
    vec3 col = at(p);
    col = mix(vec3(luma(col)), col, 1.15);
    col *= ((p.y & 1) == 0) ? 1.0 : 0.96;
    vec2 c = uv - 0.5;
    float d = dot(c, c);
    col += vec3(0.08, 0.0, 0.12) * smoothstep(0.15, 0.6, d);
    col *= 1.0 - smoothstep(0.35, 0.9, d * 2.0) * 0.22;
    fragColor = vec4(col, 1.0);
}
