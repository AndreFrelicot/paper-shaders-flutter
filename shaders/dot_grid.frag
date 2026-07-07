#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform vec4 u_colorBack;
uniform vec4 u_colorFill;
uniform vec4 u_colorStroke;
uniform float u_dotSize;
uniform float u_gapX;
uniform float u_gapY;
uniform float u_strokeWidth;
uniform float u_sizeRange;
uniform float u_opacityRange;
uniform float u_shape;


out vec4 fragColor;





float polygon(vec2 p, float N, float rot) {
  float a = atan(p.x, p.y) + rot;
  float r = TWO_PI / float(N);

  return cos(floor(.5 + a / r) * r - a) * length(p);
}

float dotDistanceAt(vec2 shapeUv, vec2 gap, float baseSize, inout float strokeWidth) {
  vec2 grid = fract(shapeUv / gap) + 1e-4;
  vec2 p = (grid - (vec2(0.5) - 1e-3)) * vec2(u_gapX, u_gapY);

  if (u_shape < 0.5) {
    return length(p);
  } else if (u_shape < 1.5) {
    strokeWidth *= 1.5;
    return polygon(1.5 * p, 4., .25 * PI);
  } else if (u_shape < 2.5) {
    return polygon(1.03 * p, 4., 1e-3);
  } else {
    strokeWidth *= 1.5;
    p = p * 2. - 1.;
    p *= .9;
    p.y = 1. - p.y;
    p.y -= .75 * baseSize;
    return polygon(p, 3., 1e-3);
  }
}

void main() {

  // x100 is a default multiplier between vertex and fragmant shaders
  // we use it to avoid UV presision issues
  vec2 shape_uv = 100. * ps_patternUV();

  vec2 gap = max(abs(vec2(u_gapX, u_gapY)), vec2(1e-6));
  vec2 grid_idx = floor(shape_uv / gap);
  float sizeRandomizer = .5 + .8 * snoise(2. * vec2(grid_idx.x * 100., grid_idx.y));
  float opacity_randomizer = .5 + .7 * snoise(2. * vec2(grid_idx.y, grid_idx.x));

  float baseSize = u_dotSize * (1. - sizeRandomizer * u_sizeRange);
  float strokeWidth = u_strokeWidth * (1. - sizeRandomizer * u_sizeRange);

  float dist = dotDistanceAt(shape_uv, gap, baseSize, strokeWidth);
  float strokeWidthX = u_strokeWidth * (1. - sizeRandomizer * u_sizeRange);
  float strokeWidthY = strokeWidthX;
  float distX = dotDistanceAt(shape_uv + 100. * ps_patternPixelStepX(), gap, baseSize, strokeWidthX);
  float distY = dotDistanceAt(shape_uv + 100. * ps_patternPixelStepY(), gap, baseSize, strokeWidthY);

  float edgeWidth = max(ps_finiteFwidth(dist, distX, distY), ps_pixelDerivative(0.5));
  float shapeOuter = 1. - smoothstep(baseSize - edgeWidth, baseSize + edgeWidth, dist - strokeWidth);
  float shapeInner = 1. - smoothstep(baseSize - edgeWidth, baseSize + edgeWidth, dist);
  float stroke = shapeOuter - shapeInner;

  float dotOpacity = max(0., 1. - opacity_randomizer * u_opacityRange);
  stroke *= dotOpacity;
  shapeInner *= dotOpacity;

  stroke *= u_colorStroke.a;
  shapeInner *= u_colorFill.a;

  vec3 color = vec3(0.);
  color += stroke * u_colorStroke.rgb;
  color += shapeInner * u_colorFill.rgb;
  color += (1. - shapeInner - stroke) * u_colorBack.rgb * u_colorBack.a;

  float opacity = 0.;
  opacity += stroke;
  opacity += shapeInner;
  opacity += (1. - opacity) * u_colorBack.a;

  fragColor = vec4(color, opacity);
}
