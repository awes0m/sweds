#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uScroll;     // 0..1 whole-journey progress
uniform vec2 uMouse;       // -1..1
uniform float uIntensity;
uniform vec3 uColorA;      // base wash
uniform vec3 uColorB;      // bloom light
uniform vec3 uColorC;      // fog tint

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  float a = hash(i), b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0)), d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = p * 2.02 + vec2(17.0, 9.0);
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;
  vec2 p = (frag - 0.5 * uSize) / uSize.y;
  p += uMouse * 0.03;

  float t = uTime * 0.035;
  vec2 q = vec2(fbm(p * 1.6 + vec2(t, -t)), fbm(p * 1.6 + vec2(5.2, 1.3) - t));
  float fog = fbm(p * 1.4 + 2.2 * q + vec2(0.0, uScroll * 3.0));

  // Bloom: a soft light that drifts with the cursor and the scroll.
  vec2 lp = vec2(0.28 + uMouse.x * 0.12, -0.22 - uScroll * 0.25 + uMouse.y * 0.08);
  float bloom = exp(-dot(p - lp, p - lp) * 2.2);
  vec2 lp2 = vec2(-0.45, 0.30 + uScroll * 0.2);
  float bloom2 = exp(-dot(p - lp2, p - lp2) * 3.4);

  vec3 col = mix(uColorA, uColorC, smoothstep(0.25, 0.80, fog) * 0.55);
  col += uColorB * (bloom * 0.42 + bloom2 * 0.22) * uIntensity;

  float g = hash(frag + floor(uTime * 12.0)) - 0.5;   // film grain
  col += g * 0.016;

  float v = smoothstep(1.15, 0.35, length(uv - 0.5) * 1.25);  // vignette
  col = mix(col * 0.93, col, v);
  fragColor = vec4(col, 1.0);
}
