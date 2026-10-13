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

// Neblina neón: glow amplio de las luces saturadas, teñido magenta. Look onírico cyberpunk.
void main() {
    SZ = textureSize(tex, 0);
    vec2 uv = v_texcoord;
    vec2 px = 1.0 / vec2(SZ);
    ivec2 p = ivec2(floor(uv * vec2(SZ)));
    vec2 c = uv - 0.5;
    float d = dot(c, c);
    vec3 base = split(p, aberr(c, 0.003));
    vec3 glow = vec3(0.0);
    float wsum = 0.0;
    for (int ring = 1; ring <= 2; ring++) {
        float r = float(ring) * 11.0;                        // 11, 22 px
        float w = 1.0 / float(ring);
        for (int i = 0; i < 6; i++) {
            float a = float(i) * 1.047198 + float(ring) * 0.5;
            vec3 s = texture(tex, uv + vec2(cos(a), sin(a)) * px * r).rgb;
            glow += s * smoothstep(0.30, 0.85, luma(s)) * (0.15 + 1.4 * sat(s)) * w;
            wsum += w;
        }
    }
    glow = glow / wsum * vec3(1.15, 0.85, 1.25);
    vec3 col = base + glow * 1.15;
    col *= 1.0 - smoothstep(0.3, 0.9, d * 2.2) * 0.33;
    fragColor = vec4(col, 1.0);
}
