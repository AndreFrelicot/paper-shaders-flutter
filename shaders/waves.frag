#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform vec4 u_colorFront;
uniform vec4 u_colorBack;
uniform float u_shape;
uniform float u_frequency;
uniform float u_amplitude;
uniform float u_spacing;
uniform float u_proportion;
uniform float u_softness;

out vec4 fragColor;

float waveShapeAt(vec2 shapeUv) {
  float wave = 0.5 * cos(shapeUv.x * u_frequency * TWO_PI);
  float zigzag = 2.0 * abs(fract(shapeUv.x * u_frequency) - 0.5);
  float irregular = sin(shapeUv.x * 0.25 * u_frequency * TWO_PI) * cos(shapeUv.x * u_frequency * TWO_PI);
  float irregular2 = 0.75 * (sin(shapeUv.x * u_frequency * TWO_PI) + 0.5 * cos(shapeUv.x * 0.5 * u_frequency * TWO_PI));

  float offset = mix(zigzag, wave, smoothstep(0.0, 1.0, u_shape));
  offset = mix(offset, irregular, smoothstep(1.0, 2.0, u_shape));
  offset = mix(offset, irregular2, smoothstep(2.0, 3.0, u_shape));
  offset *= 2.0 * u_amplitude;

  float spacing = 0.001 + u_spacing;
  return 0.5 + 0.5 * sin((shapeUv.y + offset) * PI / spacing);
}

void main() {
  vec2 shape_uv = ps_patternUV();
  shape_uv *= 4.0;

  float shape = waveShapeAt(shape_uv);
  float shapeX = waveShapeAt(shape_uv + 4.0 * ps_patternPixelStepX());
  float shapeY = waveShapeAt(shape_uv + 4.0 * ps_patternPixelStepY());

  float aa = 0.0001 + max(ps_finiteFwidth(shape, shapeX, shapeY), ps_pixelDerivative(0.5));
  float dc = 1.0 - clamp(u_proportion, 0.0, 1.0);
  float e0 = dc - u_softness - aa;
  float e1 = dc + u_softness + aa;
  float res = smoothstep(min(e0, e1), max(e0, e1), shape);

  vec3 fgColor = u_colorFront.rgb * u_colorFront.a;
  float fgOpacity = u_colorFront.a;
  vec3 bgColor = u_colorBack.rgb * u_colorBack.a;
  float bgOpacity = u_colorBack.a;

  vec3 color = fgColor * res;
  float opacity = fgOpacity * res;

  color += bgColor * (1.0 - opacity);
  opacity += bgOpacity * (1.0 - opacity);

  fragColor = vec4(color, opacity);
}
