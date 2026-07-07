#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform vec4 u_colors[10];
uniform float u_colorsCount;
uniform float u_distortion;
uniform float u_swirl;
uniform float u_grainMixer;
uniform float u_grainOverlay;

out vec4 fragColor;

vec4 mg_colorAt(int index) {
  if (index <= 0) return u_colors[0];
  if (index == 1) return u_colors[1];
  if (index == 2) return u_colors[2];
  if (index == 3) return u_colors[3];
  if (index == 4) return u_colors[4];
  if (index == 5) return u_colors[5];
  if (index == 6) return u_colors[6];
  if (index == 7) return u_colors[7];
  if (index == 8) return u_colors[8];
  return u_colors[9];
}

float mg_hash21(vec2 p) {
  p = fract(p * vec2(0.3183099, 0.3678794)) + 0.1;
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

float mg_valueNoise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  float a = mg_hash21(i);
  float b = mg_hash21(i + vec2(1.0, 0.0));
  float c = mg_hash21(i + vec2(0.0, 1.0));
  float d = mg_hash21(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  float x1 = mix(a, b, u.x);
  float x2 = mix(c, d, u.x);
  return mix(x1, x2, u.y);
}

float mg_noise(vec2 n, vec2 seedOffset) {
  return mg_valueNoise(n + seedOffset);
}

vec2 mg_rotate(vec2 uv, float th) {
  return mat2(cos(th), sin(th), -sin(th), cos(th)) * uv;
}

vec2 mg_getPosition(int i, float t) {
  float a = float(i) * 0.37;
  float b = 0.6 + fract(float(i) / 3.0) * 0.9;
  float c = 0.8 + fract(float(i + 1) / 4.0);

  float x = sin(t * b + a);
  float y = cos(t * c + a * 1.5);

  return 0.5 + 0.5 * vec2(x, y);
}

void main() {
  vec2 uv = ps_objectUV();
  uv += 0.5;
  vec2 grainUV = uv * 1000.0;

  float grain = mg_noise(grainUV, vec2(0.0));
  float mixerGrain = 0.4 * u_grainMixer * (grain - 0.5);

  const float firstFrameOffset = 41.5;
  float t = 0.5 * (u_time + firstFrameOffset);

  float radius = smoothstep(0.0, 1.0, length(uv - 0.5));
  float center = 1.0 - radius;
  for (float i = 1.0; i <= 2.0; i++) {
    uv.x += u_distortion * center / i * sin(t + i * 0.4 * smoothstep(0.0, 1.0, uv.y)) * cos(0.2 * t + i * 2.4 * smoothstep(0.0, 1.0, uv.y));
    uv.y += u_distortion * center / i * cos(t + i * 2.0 * smoothstep(0.0, 1.0, uv.x));
  }

  vec2 uvRotated = uv;
  uvRotated -= vec2(0.5);
  float angle = 3.0 * u_swirl * radius;
  uvRotated = mg_rotate(uvRotated, -angle);
  uvRotated += vec2(0.5);

  vec3 color = vec3(0.0);
  float opacity = 0.0;
  float totalWeight = 0.0;

  for (int i = 0; i < 10; i++) {
    if (i >= int(u_colorsCount)) {
      break;
    }

    vec2 pos = mg_getPosition(i, t) + mixerGrain;
    vec4 sourceColor = mg_colorAt(i);
    vec3 colorFraction = sourceColor.rgb * sourceColor.a;
    float opacityFraction = sourceColor.a;

    float dist = length(uvRotated - pos);

    dist = pow(dist, 3.5);
    float weight = 1.0 / (dist + 1e-3);
    color += colorFraction * weight;
    opacity += opacityFraction * weight;
    totalWeight += weight;
  }

  color /= max(1e-4, totalWeight);
  opacity /= max(1e-4, totalWeight);

  float grainOverlay = mg_valueNoise(mg_rotate(grainUV, 1.0) + vec2(3.0));
  grainOverlay = mix(grainOverlay, mg_valueNoise(mg_rotate(grainUV, 2.0) + vec2(-1.0)), 0.5);
  grainOverlay = pow(grainOverlay, 1.3);

  float grainOverlayV = grainOverlay * 2.0 - 1.0;
  vec3 grainOverlayColor = vec3(step(0.0, grainOverlayV));
  float grainOverlayStrength = u_grainOverlay * abs(grainOverlayV);
  grainOverlayStrength = pow(grainOverlayStrength, 0.8);
  color = mix(color, grainOverlayColor, 0.35 * grainOverlayStrength);

  opacity += 0.5 * grainOverlayStrength;
  opacity = clamp(opacity, 0.0, 1.0);

  fragColor = vec4(color, opacity);
}
