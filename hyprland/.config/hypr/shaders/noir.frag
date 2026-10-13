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

// Neo-noir (Blade Runner): gradación teal/naranja, halo suave y viñeta.
void main() {
    SZ = textureSize(tex, 0);
    vec2 uv = v_texcoord;
    vec2 px = 1.0 / vec2(SZ);
    ivec2 p = ivec2(floor(uv * vec2(SZ)));
    vec3 col = at(p);
    vec3 blur = vec3(0.0);
    for (int i = -1; i <= 1; i++) for (int j = -1; j <= 1; j++)
        blur += texture(tex, uv + vec2(float(i), float(j)) * px * 8.0).rgb;
    blur /= 9.0;
    col += blur * smoothstep(0.6, 1.0, luma(blur)) * (0.3 + 1.2 * sat(blur)) * 0.3;
    float lum = luma(col);
    col = mix(col, col * vec3(0.90, 1.0, 1.10), 1.0 - lum);
    col = mix(col, col * vec3(1.10, 1.0, 0.88), lum);
    vec2 c = uv - 0.5;
    col *= 1.0 - smoothstep(0.2, 0.8, dot(c, c) * 2.2) * 0.5;
    fragColor = vec4(col, 1.0);
}
