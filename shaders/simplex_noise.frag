#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform vec4 u_colors[10];
uniform float u_colorsCount;
uniform float u_stepsPerColor;
uniform float u_softness;

out vec4 fragColor;

vec4 sn_colorAt(int index) {
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

float getNoise(vec2 uv, float t) {
  float noise = .5 * snoise(uv - vec2(0., .3 * t));
  noise += .5 * snoise(2. * uv + vec2(0., .32 * t));
  return noise;
}

float steppedSmooth(float m, float steps, float softness, float fwidthM) {
  float stepT = floor(m * steps) / steps;
  float f = m * steps - floor(m * steps);
  float fw = steps * max(fwidthM, ps_pixelDerivative(0.5));
  float smoothed = smoothstep(.5 - softness, min(1., .5 + softness + fw), f);
  return stepT + smoothed / steps;
}

float mixerAt(vec2 shapeUv, float t) {
  float shape = .5 + .5 * getNoise(shapeUv, t);
  return (shape - .5 / u_colorsCount) * u_colorsCount;
}

void main() {
  vec2 shape_uv = ps_patternUV();
  shape_uv *= .1;

  float t = .2 * u_time;
  vec2 stepX = .1 * ps_patternPixelStepX();
  vec2 stepY = .1 * ps_patternPixelStepY();

  float mixer = mixerAt(shape_uv, t);
  float mixerX = mixerAt(shape_uv + stepX, t);
  float mixerY = mixerAt(shape_uv + stepY, t);
  float steps = max(1., u_stepsPerColor);

  vec4 gradient = sn_colorAt(0);
  for (int i = 1; i < 10; i++) {
    if (i >= int(u_colorsCount)) break;

    float localM = clamp(mixer - float(i - 1), 0., 1.);
    float localMX = clamp(mixerX - float(i - 1), 0., 1.);
    float localMY = clamp(mixerY - float(i - 1), 0., 1.);
    float fwidthM = ps_finiteFwidth(localM, localMX, localMY);
    localM = steppedSmooth(localM, steps, .5 * u_softness, fwidthM);

    vec4 c = sn_colorAt(i);
    gradient = mix(gradient, c, localM);
  }

  if ((mixer < 0.) || (mixer > (u_colorsCount - 1.))) {
    float localM = mixer + 1.;
    if (mixer > (u_colorsCount - 1.)) {
      localM = mixer - (u_colorsCount - 1.);
    }
    float localMX = mixerX + 1.;
    float localMY = mixerY + 1.;
    if (mixer > (u_colorsCount - 1.)) {
      localMX = mixerX - (u_colorsCount - 1.);
      localMY = mixerY - (u_colorsCount - 1.);
    }
    float fwidthM = ps_finiteFwidth(localM, localMX, localMY);
    localM = steppedSmooth(localM, steps, .5 * u_softness, fwidthM);
    vec4 cFst = sn_colorAt(0);
    vec4 cLast = sn_colorAt(int(u_colorsCount - 1.));
    gradient = mix(cLast, cFst, localM);
  }

  vec3 color = gradient.rgb;
  float opacity = gradient.a;
  color += 1. / 256. * (fract(sin(dot(.014 * FlutterFragCoord().xy, vec2(12.9898, 78.233))) * 43758.5453123) - .5);

  fragColor = vec4(color * opacity, opacity);
}
