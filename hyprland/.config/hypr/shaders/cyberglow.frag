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

// Cyberpunk: bloom neón (solo luces saturadas), aberración de 1-3 px, scanlines y gradación teal/magenta.
vec3 bloom(vec2 uv, vec2 px) {
    vec3 acc = vec3(0.0);
    for (int i = 0; i < 8; i++) {
        float a = float(i) * 0.785398;
        vec3 s = texture(tex, uv + vec2(cos(a), sin(a)) * px * 6.0).rgb;
        acc += s * smoothstep(0.72, 1.0, luma(s)) * (0.2 + 1.4 * sat(s));
    }
    return acc / 8.0 * 1.6;
}
void main() {
    SZ = textureSize(tex, 0);
    vec2 uv = v_texcoord;
    ivec2 p = ivec2(floor(uv * vec2(SZ)));
    vec2 c = uv - 0.5;
    float d = dot(c, c);
    vec3 col = split(p, aberr(c, 0.005));
    col += bloom(uv, 1.0 / vec2(SZ)) * 0.5;
    float l = luma(col);
    col = mix(col, col * vec3(0.93, 1.02, 1.09), 1.0 - l);       // sombras teal
    col = mix(col, col * vec3(1.07, 0.98, 1.04), l);             // luces magenta
    col *= ((p.y & 1) == 0) ? 1.0 : 0.96;
    col *= 1.0 - smoothstep(0.3, 0.9, d * 2.2) * 0.38;
    fragColor = vec4(col, 1.0);
}
