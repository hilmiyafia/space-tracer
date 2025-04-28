
#version 460 core
#define PI 3.14159265359
#include <flutter/runtime_effect.glsl>

uniform vec3 uForward;
uniform vec3 uRight;
uniform vec3 uUp;
uniform float uScale;
uniform sampler2D uTexture;
out vec4 FragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy * uScale;
    vec3 direction = normalize(uForward + uUp * uv.y + uRight * uv.x);
    float theta = acos(direction.y / length(direction)) / PI;
    float phi = sign(direction.z) * acos(direction.x / length(direction.xz));
    FragColor = texture(uTexture, vec2((1 + phi / PI) / 2, theta));
}