
#version 460 core
#define PI 3.14159265359
#include <flutter/runtime_effect.glsl>

uniform vec3 na;
uniform vec3 nb;
uniform vec3 nc;
uniform vec2 uva;
uniform vec2 uvb;
uniform vec2 uvc;
uniform sampler2D uTexture;
uniform sampler2D uEmission;
uniform sampler2D uProbe;
out vec4 FragColor;

void main() {
    vec2 coord = FlutterFragCoord().xy;
    float l1 = 1 - coord.x - coord.y;
    float l2 = coord.x;
    float l3 = 1 - l1 - l2;
    vec2 uv = uva * l1 + uvb * l2 + uvc * l3;
    vec3 direction = normalize(na * l1 + nb * l2 + nc * l3);
    float theta = acos(direction.y / length(direction)) / PI;
    float phi = sign(direction.z) * acos(direction.x / length(direction.xz));
    vec3 light = texture(uProbe, vec2((1 + phi / PI) / 2, theta)).rgb;
    vec3 emission = texture(uEmission, uv).rgb;
    light = light * (1 - emission) + emission;
    vec4 diffuse = texture(uTexture, uv);
    FragColor = vec4(diffuse.rgb * light, diffuse.a);
}